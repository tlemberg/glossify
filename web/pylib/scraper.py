# -*- coding: utf-8 -*-

from pymongo import MongoClient
from xml.etree.ElementTree import iterparse
import re
import pprint


pp = pprint.PrettyPrinter(indent=4)


def DBConnect():
	client = MongoClient('localhost', 27017)
	return client.tenk


def hashify(xs):
	r = {}
	for x in xs:
		r[x] = 1
	return r


def parse_pages(xml_file,
	valid_phrases      = None,
	max_pages          = None,
	show_progress      = False,
	process_text_f     = None,
	process_sections_f = None):

	# Initialize a count of the number of pages parsed
	n_pages_parsed = 0

	# Get the phrases we want to define
	db = DBConnect()

	context = iterparse(xml_file, events=("start", "end"))
	context = iter(context)
	event, root = context.next()

	for (event, elem) in context:
		if event == "end":
			if re.search(r'page$', elem.tag):

				# Parse the page XML
				parsed_page = parse_page(
					page         = elem,
					valid_phrases = valid_phrases)

				if parsed_page is not None:

					# Unpackage the returned values of the parsed page
					base   = parsed_page["base"]
					pageid = parsed_page["pageid"]
					text   = parsed_page["text"]

					if process_text_f is not None:
						process_text_f(base, pageid, text)
					elif process_sections_f is not None:
						# Get the sections from the text
						sections = parse_text_for_sections(base, text)

						# Call the handler method passing the parsed values
						process_sections_f(base, pageid, sections)

					# Check for hitting the maximum pages parsed if a limit is specified
					if max_pages is not None:
						n_pages_parsed += 1
						if n_pages_parsed % 10 == 0: print n_pages_parsed
						if n_pages_parsed >= max_pages: return

			root.clear()


def parse_page(page, valid_phrases=None):

	# Get the metadate for the page
	for elem in list(page):
		if re.search(r'id$', elem.tag):
			pageid = elem.text
		elif re.search(r'title$', elem.tag):
			base = elem.text

	# Find the text of the page and analyze it
	for elem in list(page):
		if re.search(r'revision$', elem.tag):
			for elem in list(elem):
				if re.search(r'text$', elem.tag):
					if valid_phrases is None or base in valid_phrases:

						# Return the base and the page text
						return {
							"base"  : base,
							"pageid": pageid,
							"text"  : elem.text,
						}

	# Page was invalid, return None
	return None


def parse_text_for_sections(text):
	sections = {}
	base_line = None
	accumulator = None

	for line in text.split("\n"):

		# Add a line to the accumulator if one exists
		if accumulator is not None:
			accumulator.append(line)

		m = re.search(r'====([A-Za-z]*?)====', line) or re.search(r'===([A-Za-z]*?)===', line)
		if m:
			# If there exists an accumulator, add its completed text to the section map
			if accumulator is not None: sections[base_line] = accumulator[:-1]

			# If we recognize the event, start an accumulator
			base_line = m.group(1)
			accumulator = []
			

	#for k in sections:
	#	if k in event_handlers:
	#		event_handler = event_handlers[k]
	#		event_handler(base, sections[k])

	return sections


def get_section_bases(db, lang):
	docs = db.sections.find(
		{
			"lang": lang,
		},
		{
			"base": 1
		}
	)

	return [doc["base"] for doc in docs]


def get_section_text(db, lang, base):
	doc = db.sections.find_one(
		{
			"lang": lang,
			"base": base
		},
		{
			"text": 1
		}
	)

	return doc["text"]



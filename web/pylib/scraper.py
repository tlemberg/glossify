# -*- coding: utf-8 -*-

import dbutils
import os
import pprint
import re
import yaml

from xml.etree.ElementTree import iterparse, XMLParser

yaml_file = os.path.join(os.environ['PROJECT_HOME'], 'web/wikidumps.yaml')
iso_codes_path = os.path.join(os.environ['PROJECT_HOME'], 'web/iso_language_codes.yaml')



################################################################################
# get_articles_dump_path
#
################################################################################
def get_articles_dump_path(lang):
	wikidumps_hash = yaml.load(open(yaml_file, 'r'))
	return wikidumps_hash[lang]['articles']


################################################################################
# get_wiktionary_dump_path
#
################################################################################
def get_wiktionary_dump_path(lang):
	wikidumps_hash = yaml.load(open(yaml_file, 'r'))
	return wikidumps_hash[lang]['wiktionary']


################################################################################
# parse_pages
#
################################################################################
def parse_pages(db, xml_file,
	valid_phrases      = None,
	max_pages          = None,
	show_progress      = False,
	process_text_f     = None,
	process_sections_f = None):

	# Initialize a count of the number of pages parsed
	n_pages_parsed = 0

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
						if show_progress and n_pages_parsed % 10 == 0: print n_pages_parsed
						if n_pages_parsed >= max_pages: return

			root.clear()


################################################################################
# parse_page
#
################################################################################
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


################################################################################
# parse_text_for_sections
#
################################################################################
def parse_text_for_sections(text):
	sections = {}
	base_line = None
	accumulator = None

	for line in text.split("\n"):

		# Add a line to the accumulator if one exists
		if accumulator is not None:
			accumulator.append(line)

		m = re.search(r'====([A-Za-z\s]*?)====', line) or re.search(r'===([A-Za-z\s]*?)===', line)
		if m:
			# If there exists an accumulator, add its completed text to the section map
			if accumulator is not None:
				sections[base_line] = accumulator[:-1]

			# If we recognize the event, start an accumulator
			base_line = m.group(1)
			accumulator = []
			
	if accumulator is not None:
		sections[base_line] = accumulator[:-1]

	#for k in sections:
	#	if k in event_handlers:
	#		event_handler = event_handlers[k]
	#		event_handler(base, sections[k])

	return sections


################################################################################
# get_section_bases
#
################################################################################
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


################################################################################
# get_section_text
#
################################################################################
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


################################################################################
# Read
#
################################################################################
def get_iso_codes_hash():
	return yaml.load(open(iso_codes_path, 'r'))


################################################################################
# get_viewable_txs
#
################################################################################
def get_viewable_txs(phrase):
	priority = sorted(phrase['txs'].keys(), key = lambda t: len(phrase['txs'][t]))
	new_txs = {}
	for k in priority[:2]:
		v = phrase['txs'][k]
		if v == []:
			continue
		x = [tx for tx in v if not tx['deleted']]
		x = sorted(x, key = lambda a: a['rank'])
		x = x[0:3]
		x = [tx['text'] for tx in x]
		new_txs[k] = x
	return new_txs


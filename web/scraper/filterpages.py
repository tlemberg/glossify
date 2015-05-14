#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import *
from frequencies import get_valid_phrase_map
import difflib
import argparse


# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("filename_in")


# Parse the arguments
args = parser.parse_args()


# Define a mapping of language keys in the wiki to 2-digit language codes
language_key_map = {
	"French": "fr"
}


# Connect to the DB
db = DBConnect()


def Main() :

	# Remove existing entries
	for language_code in language_key_map.values():
		db.sections.remove({
			"lang": language_code,
		})

	# Get the total phrase counts as a list of dictionaries
	#valid_phrases_map = get_valid_phrase_map(db)

	# Parse the pages of the xml file specified as an cmd-line argument
	parse_pages(
		xml_file       = args.filename_in,
		valid_phrases  = None, #valid_phrases_map,
		process_text_f = process_text,
		show_progress  = True,
		max_pages      = None
	)


def process_text(base, page_id, text):

	# Specify a pattern for identifying language headers in the text
	valid_language_keys = hashify(language_key_map.keys())

	# Initialize a map of languages to section texts
	sections = {}

	language_key = None
	accumulator = None

	# Create a hash from the raw text
	if text:
		for line in text.split("\n"):

			# If an accumulator exists, add the current line to the accumulator
			if accumulator is not None:
				accumulator.append(line)

			# Check if the language section has changed
			m = re.search(r'^==([A-Za-z\s]+)==$', line)
			if m:
				# If the current language key is in the list of valid keys, add the accumulator to the sections dictionary
				if accumulator is not None and language_key in valid_language_keys:
					sections[language_key] = accumulator[:-1]

				# Specify the new language key and reset the accumulator
				language_key = m.group(1)
				accumulator = []
		
		if accumulator is not None and language_key in valid_language_keys:
			sections[language_key] = accumulator

		# Iterate through the sections and write them to the database
		for (k, v) in sections.iteritems():
			write_section(k, base, "\n".join(v))
			pass


def write_section(language_key, base, text):

	# Return if the language key isn't in the map
	if language_key not in language_key_map: return

	# Insert all of the new entries
	new_id = db.sections.insert({
		"lang": language_key_map[language_key],
		"base": base,
		"text": text,
	})


Main()
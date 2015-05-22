#!/usr/bin/env python
# -*- coding: utf-8 -*-

import app.utils
import argparse
import dbutils
import re
import scraper

from xml.etree.ElementTree import iterparse

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")

# Parse the arguments
args = parser.parse_args()

# Define a mapping of language keys in the wiki to 2-digit language codes
language_key_map = {
	"fr": "French",
	"es": "Spanish",
	"ru": "Russian",
}

# Connect to the DB
db = dbutils.DBConnect()


################################################################################
# Main
#
################################################################################
def Main() :

	# Remove existing entries
	db.sections.remove({
		"lang": args.lang,
	})

	xml_file = scraper.get_wiktionary_dump_path('en')

	# Parse the pages of the xml file specified as an cmd-line argument
	scraper.parse_pages(db,
		xml_file       = xml_file,
		valid_phrases  = None,
		process_text_f = process_text,
		show_progress  = True,
		max_pages      = None
	)


################################################################################
# process_text
#
################################################################################
def process_text(base, page_id, text):

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
				if accumulator is not None and language_key == language_key_map[args.lang]:
					sections[language_key] = accumulator[:-1]

				# Specify the new language key and reset the accumulator
				language_key = m.group(1)
				accumulator = []
		
		if accumulator is not None and language_key == language_key_map[args.lang]:
			sections[language_key] = accumulator

		# Iterate through the sections and write them to the database
		for (k, v) in sections.iteritems():
			write_section(k, base, "\n".join(v))
			pass


################################################################################
# write_section
#
################################################################################
def write_section(language_key, base, text):

	# Return if the language key isn't in the map
	if language_key not in language_key_map.values(): return

	# Insert all of the new entries
	new_id = db.sections.insert({
		"lang": app.utils.reverse_hash(language_key_map)[language_key],
		"base": base,
		"text": text,
	})


Main()

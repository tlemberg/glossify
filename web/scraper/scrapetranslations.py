#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import *
from frequencies import *
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("--base")
args = parser.parse_args()


# Define valid section keys
valid_section_keys = [
	'Adverb',
	'Numeral',
	'Verb',
	'Article',
	'Conjunction',
	'Noun',
	'Particle',
	'Pronoun',
	'Adjective',
	'Preposition',
	'Synonyms',
	'Phrase'
]


# Connect to the database and get a list of phrases
db = DBConnect()


# Make a rank map
rank_map = {}
for doc in db.total_phrase_counts.find({}, { 'phrase': 1, 'rank': 1 }):
	rank_map[doc['phrase']] = doc['rank']

print "Rank map complete!"


def Main() :
	# Construct a list of the base words to translate, then interate over it
	if args.base is not None:
		bases = [args.base]
	else:
		bases = get_section_bases(db, "fr")

	for base in bases:
		# Get the text for that base
		text = get_section_text(db,
			lang = "fr",
			base = base)

		# Get the translations
		doc = process_text(base, text)

		# Write the document if it exists
		if doc is not None:
			write_translations(doc)


def process_text(base, text):

	# Extract sections from the text
	sections = parse_text_for_sections(text)

	# Initialize a document to insert
	txs = {}

	for k in sections:
		if k in valid_section_keys:
			translations = get_translations(sections[k])
			if translations != []: txs[k] = translations

	
	rank = rank_map[base]

	if txs != {} and rank is not None:
		return {
			"lang": "fr",
			"base": base,
			"rank": rank,
			"txs" : txs
		}


def get_translations(lines):
	txs = []
	rank = 1
	for line in lines:
		m = re.search(r'^# (.*)$', line) or re.search(r'^\* (.*)$', line)
		if m:
			s = m.group(1)
			s = re.sub(r'\{\{.*?\}\}', '', s)
			s = re.sub(r'\[\[', '', s)
			s = re.sub(r'\]\]', '', s)
			s = re.sub(r'=', '', s)
			s = s.strip()
			if s != '':
				txs.append({
					"text"   : s,
					"rank"   : rank,
					"deleted": False,
				})
				rank += 1

	return txs


def write_translations(doc):
	# Remove existing entries
	db.phrases.remove({ "base": doc["base"] })

	# Insert all of the new entries
	db.phrases.insert(doc)


Main()
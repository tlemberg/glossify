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
parser.add_argument("--base")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = dbutils.DBConnect()

# Define valid section keys
valid_section_keys = [
	'Adverb',
	'Numeral',
	'Cardinal numeral',
	'Verb',
	'Article',
	'Conjunction',
	'Contraction',
	'Noun',
	'Particle',
	'Pronoun',
	'Adjective',
	'Preposition',
	'Synonyms',
	'Phrase',
	'Proper noun',
]

# Make a rank map
rank_map = {}
for doc in db.phrases.find({ 'lang': args.lang }, { 'base': 1, 'rank': 1 }):
	rank_map[doc['base']] = doc['rank']


################################################################################
# Main
#
################################################################################
def Main() :

	phrases = None

	if args.base != None:
		phrases = db.phrases.find(
			{
				'lang': args.lang,
				'base': args.base,
			},
		).sort('rank', 1)
	else:
		print "update lang"
		db.phrases.update(
			{
				'lang': args.lang,
			},
			{
				'$unset': 
					{ 'txs': 1 }
			},
			multi=True,
			upsert=True,
		)
		phrases = db.phrases.find({ 'lang': args.lang }).sort('rank', 1)

	print "Starting..."

	count = 0
	for phrase in phrases:
		section = dbutils.get_section_for_phrase(db, phrase)

		if section != None:
			base = phrase['base']
			text = section['text']

			print phrase['base']

			# Get the translations
			tx_hash = process_text(base, text)

			# Write the document if it exists
			if tx_hash is not None:
				write_translations(base, tx_hash)
				count += 1
				if count % 100 == 0:
					print count


################################################################################
# process_text
#
################################################################################
def process_text(base, text):

	# Extract sections from the text
	sections = scraper.parse_text_for_sections(text)

	# Initialize a document to insert
	txs = {}

	for k in sections:
		if k in valid_section_keys:
			translations = get_translations(sections[k])
			txs[k] = translations

	
	rank = rank_map[base]

	if txs != {} and rank is not None:
		return txs


################################################################################
# get_translations
#
################################################################################
def get_translations(lines):
	txs = []
	rank = 1
	for line in lines:
		m = re.search(r'^# (.*)$', line) or re.search(r'^#\{\{(.*)$', line) or re.search(r'^#\[\[(.*)$', line) or re.search(r'^\* (.*)$', line)
		if m:
			s = line #m.group(1)
			s = re.sub(r'\{\{.*?\}\}', '', s)
			s = re.sub(r'\[\[', '', s)
			s = re.sub(r'\]\]', '', s)
			s = re.sub(r'=', '', s)
			s = re.sub(r'#', '', s)
			s = s.strip()
			if s != '':
				txs.append({
					"text"   : s,
					"rank"   : rank,
					"deleted": False,
				})
				rank += 1

	return txs


################################################################################
# write_translations
#
################################################################################
def write_translations(base, tx_hash):

	# Insert all of the new entries
	phrase = db.phrases.find_one({
		'lang': args.lang,
		'base': base,
	})

	phrase['txs'] = tx_hash

	db.phrases.update(
		{
			'lang': args.lang,
			'base': base,
		},
		phrase,
	)


Main()
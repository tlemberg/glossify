#!/usr/bin/env python
# -*- coding: utf-8 -*-

import app.utils
import argparse
import dbutils
import re
import scraper

from xml.etree.ElementTree import iterparse
from datetime              import datetime

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")
parser.add_argument("--base")
parser.add_argument("--skipto")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = dbutils.DBConnect()
coll = db["phrases_%s" % args.lang]

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
	'Determiner',
]

# Make a rank map
rank_map = {}
for doc in coll.find({ }, { 'base': 1, 'rank': 1 }):
	rank_map[doc['base']] = doc['rank']


################################################################################
# Main
#
################################################################################
def Main() :

	phrases = None

	if args.base != None:
		phrases = coll.find(
			{
				'base': args.base,
			},
		).sort('rank', 1)
	else:
		print "update lang"
		coll.update(
			{ },
			{
				'$unset': 
					{ 'txs': 1 }
			},
			multi=True,
			upsert=True,
		)
		phrases = coll.find({ }).sort('rank', 1)

	print "Starting..."

	count = 0
	started = False
	for phrase in phrases:
		if args.skipto and not started:
			if phrase['base'] == args.skipto:
				started = True
			else:
				continue

		#print phrase['base']
		t0 = datetime.now()
		section = dbutils.get_section_for_phrase(db, phrase)
		t1 = datetime.now()
		#print "  get section: ", (t1-t0)

		if section != None:
			base = phrase['base']
			text = section['text']

			# Get the translations
			t0 = datetime.now()
			tx_hash = process_text(base, text)
			t1 = datetime.now()
			#print "  process: ", (t1-t0)

			# Write the document if it exists
			if tx_hash is not None:
				t0 = datetime.now()
				write_translations(base, tx_hash)
				t1 = datetime.now()
				#print "  insert: ", (t1-t0)
				count += 1
				if count % 100 == 0:
					print count

	if args.base:
		section = dbutils.get_section_for_phrase(db, phrase)
		phrase = coll.find_one(
			{
				'base': args.base,
			},
		)
		print section['text']
		print phrase['txs']


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
			if translations != []:
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
	strings = []
	for line in lines:
		m = re.search(r'^#', line)
		if m == None:
			continue
		m = re.search(r'^#\*', line)
		if m:
			continue
		m = re.search(r'^#\:', line)
		if m:
			continue

		m = re.search(r'^# \[\[', line)
		if m:
			########################
			# Pattern 1:
			# [[a]], [[b]], [[c]]
			########################
			m = re.findall(r'\[\[(.*?)\]\]', line)
			if m:
				for s in m:
					strings.append(f6(s))
				continue

		m = re.search(r'^# \{\{context\|(.*?)\|lang', line)
		if m:
			context = f6(m.group(1))
			if context == 'archaic':
				continue
			else:
				########################
				# Pattern 2:
				# [[a]], [[b]], [[c]]
				########################
				m2 = re.findall(r'\[\[(.*?)\]\]', line)
				if m2:
					for s in m2:
						if args.lang == 'zh' and re.search('Chinese|Mandarin', m.group(1)):
							strings.append("%s" % (f6(s)))
						else:
							strings.append("%s (%s)" % (f6(s), context))
					continue

		m = re.search(r'^# (.*)$|^## (.*)$|^#\{\{(.*)$|^#\[\[(.*)$|^\* (.*)$', line)
		if m:
			s = ''
			########################
			# Pattern 3:
			# {{l/en|as}}{{l/en|as}}
			########################
			m = re.search(r'\{\{l\/en\|(.*)\}\}', line)
			if m:
				strings.append(f6(m.group(1)))
				continue

			


		########################
		# All other patterns:
		########################
		m = re.findall(r'\[\[(.*?)\]\]', line)
		if m:
			for s in m:
				strings.append(f6(s))
			continue
		m = re.search(r'\((.*?)\)', line)
		if m:
			strings.append(f6(m.group(1)))

			

	for s in f7(strings):
		if s == '':
			continue
		if s.find('#') >= 0:
			continue
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
	phrase = coll.find_one({
		'base': base,
	})

	phrase['txs'] = tx_hash

	coll.update(
		{
			'base': base,
		},
		phrase,
	)


def f6(s):
	i = s.find('|')
	if i >= 0:
		s = s[:i]
	s = re.sub(r'\[\[(.*?)\]\]', r'\1', s)
	return s


def f7(seq, idfun=None): 
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       # in old Python versions:
       # if seen.has_key(marker)
       # but in new ones:
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result


Main()
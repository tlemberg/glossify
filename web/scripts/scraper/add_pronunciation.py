#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import argparse
import dbutils
import re
import scraper

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")

# Parse the arguments
args = parser.parse_args()

# Connect to the database and get a list of phrases
db = dbutils.DBConnect()
coll_name = "phrases_%s" % args.lang
coll = db[coll_name]

def main():
	if args.lang == 'zh':
		coll.update(
			{ },
			{
				'$unset': {'trad': 1},
			},
			multi=True,
		)

	# Choose a function
	f_map = {
		'he': get_pronunciation_he,
		'zh': get_pronunciation_zh,
	}
	get_pronunciation_f = f_map[args.lang]

	count = 0
	cursor = coll.find({ 'txs': {'$exists': 1 } })
	total_count = cursor.count()
	for phrase in cursor:
		section = dbutils.get_section_for_phrase(db, phrase)
		if section != None:
			updates = get_pronunciation_f(phrase, section['text'])
			if updates:
				coll.update(
					{
						'base': phrase['base']
					},
					{
						'$set': updates,
					},
					multi=True,
					upsert=True,
				)
		count += 1
		print "\r", "{0:.2f}".format(100. * float(count) / float(total_count)), '%',


################################################################################
# HE
#
################################################################################
def get_pronunciation_he(phrase, text):
	sections = scraper.parse_text_for_sections(text)
	for k, v in sections.iteritems():
		if k in phrase['txs'].keys():
			m = re.search(r'\|tr=(.*?)\}\}', v[0])
			if m and re.search(r'\|', m.group(1)):
				m = None
			if not m:
				m = re.search(r'\|tr=(.*?)\|', v[0])
			if m:
				pron = m.group(1)
				pron = pron.replace(u'&iacute;', u'í')
				return {'pron': pron}


################################################################################
# ZH
#
################################################################################
def get_pronunciation_zh(phrase, text):

	# Pronunciation
	pron = None
	m = re.search(r'\n\|m=(.*?)\|', text)
	if not m:
		m = re.search(r'\n\|m=(.*?),', text)
		if not m:
			m = re.search(r'\n\|m=(.*?)\n', text)
	if m:
		pron = m.group(1)

	# Traditional
	trad = None
	m = re.search(r'\{\{zh-forms\|s=(.*?)\}\}', text)
	if m:
		if m.group(1) != phrase['base']:
			trad = True

	if trad:
		return {'pron': pron, 'trad': 1}
	else:
		return {'pron': pron}

if __name__ == "__main__":
	main()

#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import argparse
import dbutils
import dictionary
import itsdangerous
from bson.json_util import dumps
import os
import scraper

def create_dictionary_from_cursor(lang, cursor, max_entries=10000):
	l = list(cursor)
	q = []
	d = {}

	include_pron = lang in ['he', 'zh']
	include_strokes = lang in ['zh']

	# Create a list of entries with the appropriate fields
	for phrase in l:

		if 'txs' in phrase and phrase['txs'] != {}:
			new_txs = scraper.get_viewable_txs(phrase)

			to_append = {
				'lang': phrase['lang'],
				'base': phrase['base'],
				'txs' : new_txs,
				'_id': str(phrase['_id']),
				'rank': phrase['rank'],
			}
			if include_pron:
				to_append['pron'] = phrase['pron']
			if include_strokes and 'strokes' in phrase.keys():
				to_append['strokes'] = phrase['strokes']

			if new_txs != {}:
				q.append(to_append)

	# Convert the list into a dictionary based on ID, limiting by number of entries
	for h in q[0:max_entries]:
		d[h['_id']] = h
	
	return d


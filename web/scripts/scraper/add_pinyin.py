#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import dbutils
import re

# Connect to the database and get a list of phrases
db = dbutils.DBConnect()

count = 0
cursor = db.phrases_zh.find({ 'txs': {'$exists': 1 } })
total_count = cursor.count()
for phrase in cursor:
	section = dbutils.get_section_for_phrase(db, phrase)
	if section != None:
		m = re.search(r'\n\|m=(.*?)\|', section['text'])
		if not m:
			m = re.search(r'\n\|m=(.*?),', section['text'])
			if not m:
				m = re.search(r'\n\|m=(.*?)\n', section['text'])
		if m:
			db.phrases_zh.update(
				{
					'base': phrase['base']
				},
				{
					'$set': {
						'pron': m.group(1),
					},
				},
				multi=True,
				upsert=True,
			)

	count += 1
	print "\r", "{0:.2f}".format(100. * float(count) / float(total_count)), '%',
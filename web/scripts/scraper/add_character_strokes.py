#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import argparse
import dbutils
import os
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

coll.update(
	{

	},
	{
		'$unset': {
			'strokes': 1,
		}
	}
)

def main():
	count = 0
	cursor = coll.find({ 'txs': {'$exists': 1 } })
	total_count = cursor.count()
	for phrase in cursor:
		gb2312_strs = []
		n_chars = 0

		for utf8_char in phrase['base']:
			gb2312_str = None
			n_chars += 1
			try:
				gb2312_str = scraper.get_gb2312_str(utf8_char)
			except UnicodeEncodeError:
				print "Skipping character %s..." % utf8_char
				break

			if gb2312_str:
				path = os.path.join('/data/tmp/strokes', "%s.gif" % gb2312_str)
				if os.path.exists(path):
					gb2312_strs.append(gb2312_str)

		if len(gb2312_strs) == n_chars:
			coll.update(
				{
					'_id': phrase['_id'],
				},
				{
					'$set': {
						'strokes': gb2312_strs,
					}
				}
			)

		count += 1
		print "\r", "{0:.2f}".format(100. * float(count) / float(total_count)), '%',

main()
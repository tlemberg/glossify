#!/usr/bin/env python
# -*- coding: utf-8 -*-

import app.utils
import argparse
import dbutils
import re
import scraper
import pymongo

from xml.etree.ElementTree import iterparse

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = dbutils.DBConnect()
coll_name = "phrases_%s" % args.lang
db.drop_collection(coll_name)
coll = db[coll_name]


################################################################################
# Main
#
################################################################################
def Main():

	print "Creating index 1..."
	coll.create_index([
		('rank', pymongo.ASCENDING),
	])

	print "Creating index 2..."
	coll.create_index([
		('base', pymongo.ASCENDING),
	])

	print "Getting phrase counts..."
	total_phrase_counts = get_total_phrase_counts(db, coll)


################################################################################
# get_total_phrase_counts
#
################################################################################
def get_total_phrase_counts(db, coll):

	# Get a cursor to all of the phrase count documents in the database
	phrase_counts = db.phrase_counts.find({ 'lang': args.lang })

	total_count = 0

	# Iterate over the phrase count documents in the cursor
	broken = False
	for phrase_count in phrase_counts:

		for phrase_length in phrase_count['counts']:
			for base in phrase_count['counts'][phrase_length]:
				count = phrase_count['counts'][phrase_length][base]
				inc_count = min(count, 10)
				doc = coll.find_one({ 'base': base })
				if doc:
					coll.update({ 'base': base }, { '$inc': { 'count': inc_count } })
				else:
					coll.insert({
						'lang' : args.lang,
						'base' : base,
						'count': inc_count,
					})
					total_count += 1
				if total_count >= 1000000:
					broken = True
					break
			if broken:
				break
		if broken:
				break


	phrases = coll.find().sort('count', pymongo.DESCENDING)
	rank = 1
	for phrase in phrases:
		coll.update({ 'base': phrase['base'] }, { '$set': { 'rank': rank } })
		rank += 1



Main()

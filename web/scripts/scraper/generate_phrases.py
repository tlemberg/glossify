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

# Connect to the DB
db = dbutils.DBConnect()


################################################################################
# Main
#
################################################################################
def Main():
	# Connect to the DB
	db = dbutils.DBConnect()

	db.phrases.remove({ 'lang': args.lang })

	# Get the total phrase counts as a list of dictionaries
	total_phrase_counts = get_total_phrase_counts(db)

	# Write the dictionaries to a new table
	db.phrases.insert(total_phrase_counts)


################################################################################
# get_total_phrase_counts
#
################################################################################
def get_total_phrase_counts(db):

	# Get a cursor to all of the phrase count documents in the database
	phrase_counts = db.phrase_counts.find({ 'lang': args.lang })

	# Iterate over the phrase count documents in the cursor
	count_map = {}
	for phrase_count in phrase_counts:

		for phrase_length in phrase_count['counts']:
			for base in phrase_count['counts'][phrase_length]:
				count = phrase_count['counts'][phrase_length][base]
				if base not in count_map:
					count_map[base] = {
						'lang' : args.lang,
						'base' : base,
						'count': count
					}
				else:
					count_map[base]['count'] += count

	# Grab the total phrase counts as a list and sort them
	total_phrase_counts = [v for v in count_map.values() if v['count'] > 10]
	total_phrase_counts = sorted(total_phrase_counts, key=lambda phrase_count: phrase_count['count'], reverse=True)

	# Assign a rank to every phrase count in the list
	rank = 1
	for phrase_count in total_phrase_counts:
		phrase_count['rank'] = rank
		rank += 1

	# Write more than the desired 10k phrases, because some will be invalid
	return total_phrase_counts


Main()

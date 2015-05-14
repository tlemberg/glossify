# -*- coding: utf-8 -*-

from pymongo import MongoClient
from scraperutils import *


language_code = 'fr'


def Main():
	# Connect to the DB
	db = DBConnect()

	db.total_phrase_counts.remove({ 'lang': language_code })

	# Get the total phrase counts as a list of dictionaries
	total_phrase_counts = get_total_phrase_counts(db)

	# Write the dictionaries to a new table
	write_total_phrase_counts(db, total_phrase_counts)


def get_total_phrase_counts(db):

	# Get a cursor to all of the phrase count documents in the database
	phrase_counts = db.phrase_counts.find({ 'lang': language_code })

	# Iterate over the phrase count documents in the cursor
	count_map = {}
	for phrase_count in phrase_counts:

		for phrase_length in phrase_count['counts']:
			for base in phrase_count['counts'][phrase_length]:
				count = phrase_count['counts'][phrase_length][base]
				if base not in count_map:
					count_map[base] = {
						'lang' : language_code,
						'base' : base,
						'count': count
					}
				else:
					count_map[base]['count'] += count

	# Grab the total phrase counts as a list and sort them
	total_phrase_counts = count_map.values()
	total_phrase_counts = sorted(total_phrase_counts, key=lambda phrase_count: phrase_count['count'], reverse=True)

	# Assign a rank to every phrase count in the list
	rank = 1
	for phrase_count in total_phrase_counts:
		phrase_count['rank'] = rank
		rank += 1

	# Write more than the desired 10k phrases, because some will be invalid
	return total_phrase_counts[:20000]


def write_total_phrase_counts(db, total_phrase_counts):

	# Remove existing entries
	db.total_phrase_counts.remove()

	# Insert all of the new entries
	db.total_phrase_counts.insert(total_phrase_counts)


Main()
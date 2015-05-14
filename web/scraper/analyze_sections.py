# -*- coding: utf-8 -*-

from pymongo import MongoClient
from scraperutils import *


language_code = 'fr'


def Main():
	# Connect to the DB
	db = DBConnect()

	phrase_counts = db.total_phrase_counts.find({ 'lang': language_code })
	i = 0
	n = 0
	for phrase_count in phrase_counts:
		base = phrase_count["base"]

		invalid = False

		section = db.sections.find_one({ 'base': base })
		if section == None:
			section = db.sections.find_one({ 'base': base.title() })
			if section == None:
				section = db.sections.find_one({ 'base': base.upper() })
				if section == None:
					n += 1
					invalid = True

		if not invalid:
			print base

		# Limit
		i += 1
		if i == 5000:
			break

	print "Num broken: %d" % n


Main()
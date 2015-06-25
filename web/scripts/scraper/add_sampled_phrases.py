#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient
from random import shuffle

import argparse
import dbutils
import pymongo
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

coll.remove({'count': 0})

bases = {}
for phrase in coll.find({}, {'base': 1}):
	bases[phrase['base']] = 1

new_bases = []
for section in db.sections.find({ 'lang': args.lang }, { 'base': 1 }):
	base = section['base']
	if bases.get(base):
		new_bases.append(base)

max_rank = coll.find({}, {'rank': 1}).sort('rank', pymongo.DESCENDING).limit(1)[0]['rank']

print "Adding %d new phrases" % len(new_bases)

shuffle(new_bases)
docs = [
	{
		'lang': args.lang,
		'base': new_bases[i],
		'count': 0,
		'rank': max_rank + i + 1,
	}
for i in range(0,min(10000,len(new_bases)))]

coll.insert(docs)

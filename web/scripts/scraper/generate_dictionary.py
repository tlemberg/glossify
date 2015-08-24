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

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")

# Parse the arguments
args = parser.parse_args()

# Connect to the database and get a list of phrases
db = dbutils.DBConnect()
coll = db["phrases_%s" % args.lang]

restrictions = {
	'txs': {'$exists': 1 },
}
include_pron = args.lang in ['he', 'zh']
include_strokes = args.lang in ['zh']
if include_pron:
	restrictions['pron'] = { '$exists': 1 }
if args.lang == 'zh':
	restrictions['trad'] = { '$exists': 0 }

cursor = coll.find(restrictions)

coll.update(
	{ },
	{
		'$set': {
			'in_plan': 0,
		},
	},
	multi=True,
	upsert=True,
)

d = dictionary.get_dictionary_from_cursor(lang, cursor)

for h in d.values():
	coll.update(
		{
			'base': h['base'],
		},
		{
			'$set': {
				'in_plan': 1,
			},
		},
		multi=True,
		upsert=True,
	)

obj = {
	'success': 1,
	'result' : {
		'lang': 'args.lang',
		'dictionary': d,
	},
}

s = dumps(obj)

#serializer = itsdangerous.URLSafeSerializer('f15908888b0c1fa33bcf89c04f2d2410e4f9a81d6e764538')
#encrypted_s = serializer.dumps(s)

path = os.path.join(os.environ['PROJECT_HOME'], "web/templates/dictionaries/%s.json" % args.lang)
with open(path, "w") as f:
	f.write(s)

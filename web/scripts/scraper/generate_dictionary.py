#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import argparse
import dbutils
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
if include_pron:
	restrictions['pron'] = { '$exists': 1 }
if args.lang == 'zh':
	restrictions['trad'] = { '$exists': 0 }

cursor = coll.find(
	restrictions,
	{
		"_id" : 1,
		"lang": 1,
		"base": 1,
		"txs" : 1,
		"rank": 1,
		"pron": 1
	}
)

l = list(cursor)
q = []
d = {}

for phrase in l:
	if 'txs' in phrase and phrase['txs'] != {}:
		new_txs = scraper.get_viewable_txs(phrase)

		to_append = {
			'lang': phrase['lang'],
			'base': phrase['base'],
			'txs' : new_txs,
			'_id': str(phrase['_id']),
		}
		if include_pron:
			to_append['pron'] = phrase['pron']

		if new_txs != {}:
			q.append(to_append)

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
for h in q[0:10000]:
	d[h['_id']] = h
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

print len(d.keys())

obj = {
	'success': 1,
	'result' : {
		'lang': 'is',
		'dictionary': d,
	},
}

s = dumps(obj)

#serializer = itsdangerous.URLSafeSerializer('f15908888b0c1fa33bcf89c04f2d2410e4f9a81d6e764538')
#encrypted_s = serializer.dumps(s)

path = os.path.join(os.environ['PROJECT_HOME'], "web/templates/dictionaries/%s.json" % args.lang)
with open(path, "w") as f:
	f.write(s)

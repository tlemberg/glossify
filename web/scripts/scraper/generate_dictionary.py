#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import argparse
import dbutils
import itsdangerous
from bson.json_util import dumps
import os

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")

# Parse the arguments
args = parser.parse_args()

# Connect to the database and get a list of phrases
db = dbutils.DBConnect()

cursor = db.phrases.find(
	{
		"lang": args.lang,
	},
	{
		"_id" : 1,
		"lang": 1,
		"base": 1,
		"txs" : 1,
		"rank": 1,
	}
)

l = list(cursor)
q = []
d = {}

for phrase in l:
	if 'txs' in phrase and phrase['txs'] != {}:
		new_txs = {}
		for k, v in phrase['txs'].iteritems():
			 x = [tx for tx in v if not tx['deleted']]
			 x = sorted(x, key = lambda a: a['rank'])
			 x = x[0:3]
			 x = [tx['text'] for tx in x]
			 new_txs[k] = x

		q.append({
			'lang': phrase['lang'],
			'base': phrase['base'],
			'txs' : new_txs,
			'_id': str(phrase['_id']),
		})

db.phrases.update(
	{
		'lang': args.lang,
	},
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
	db.phrases.update(
		{
			'lang': args.lang,
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
		'lang': 'fr',
		'dictionary': d,
	},
}

s = dumps(obj)

#serializer = itsdangerous.URLSafeSerializer('f15908888b0c1fa33bcf89c04f2d2410e4f9a81d6e764538')
#encrypted_s = serializer.dumps(s)

path = os.path.join(os.environ['PROJECT_HOME'], "web/templates/dictionaries/%s.json" % args.lang)
with open(path, "w") as f:
	f.write(s)

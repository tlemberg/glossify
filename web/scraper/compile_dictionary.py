#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

from scraperutils import *
from bson.json_util import dumps

# Connect to the database and get a list of phrases
db = DBConnect()

cursor = db.phrases.find(
	{
		"lang": "fr",
	},
	{
		"lang": 1,
		"base": 1,
		"txs" : 1,
		"_id" : 1,
	}
)

l = list(cursor)
d = {}
for phrase in l:
	_id = "%s" % phrase['_id']
	d[_id] = {
		'lang': phrase['lang'],
		'base': phrase['base'],
		'txs' : phrase['txs'],
		'_id' : str(phrase['_id']),
	}

obj = {
	'success': 1,
	'result' : {
		'lang': 'fr',
		'dictionary': d,
	},
}

print obj

s = dumps(obj)

with open("templates/dictionaries/fr.json", "w") as f:
	f.write(s)

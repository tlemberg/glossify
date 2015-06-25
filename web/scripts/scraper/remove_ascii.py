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

badBases = []
for phrase in coll.find({ }, { 'base': 1 }):
	if re.search(r'[A-Za-z]', phrase['base']):
		badBases.append(phrase['base'])

for base in badBases:
	coll.remove({ 'base': base })
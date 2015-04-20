#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import *
from frequencies import *
from models.phrases import get_total_phrase_counts
import difflib
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("searchword")
parser.add_argument("--templates", action="store_true")
args = parser.parse_args()

filenamein = "/data/wikidumps/enwiktionary-filtered.xml"
if args.templates:
	filenamein = "/data/wikidumps/frwiktionary-templates.xml"

alphabet = {
	"lowercase": u"abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": u"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

alphabetpattern = "[%s]" % "|".join(list(alphabet["lowercase"]))


def Main() :
	nblocks = 0

	# Get the phrases we want to define
	db = DBConnect()
	total_phrase_counts = get_total_phrase_counts(db)
	validphrases = [x["phrase"] for x in total_phrase_counts[:1000]]

	validphrasehash = dict([[x, 1] for x in validphrases])

	with open(filenamein) as f_in:
		blocklines = []
		base = ""
		for line in f_in:
			if re.search(r'<page>', line):
				blocklines = []
				base = ""
			blocklines.append(line)
			m = re.search(r'<title>(.*)</title>', line)
			if m:
				base = m.group(1)
			if re.search(r'</page>', line):
				print base
				#if is_valid_phrase(base, validphrases):
				if re.search(r"%s$" % args.searchword, base):
					print "".join(blocklines)
					break

Main()
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import *
from frequencies import get_valid_phrase_map
import difflib
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("filenamein")
parser.add_argument("filenameout")
parser.add_argument("--templates", action="store_true")
args = parser.parse_args()

alphabet = {
	"lowercase": u"abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": u"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

alphabetpattern = "[%s]" % "|".join(list(alphabet["lowercase"]))


def Main() :
	nblocks = 0

	# Get the phrases we want to define as a map
	db = DBConnect()
	valid_phrase_map = get_valid_phrase_map(db)

	with open(args.filenamein) as f_in:
		with open(args.filenameout, "w") as f_out:

			f_out.write("<body>\n")
			f_out.flush()

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
					#if is_valid_phrase(base, validphrases):
					shouldwrite = False
					if args.templates:
						m = re.search(r'Documentation|\/', base)
						if not m:
							shouldwrite = re.search(r'le\:(fr.*)$', base, re.UNICODE)
					else:
						shouldwrite = base in valid_phrase_map
					if shouldwrite:
						f_out.write("".join(blocklines))
						f_out.flush()
						nblocks += 1
						print "%s %d" % (base, nblocks)

			f_out.write("</body>\n")
			f_out.flush()



Main()
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import parse_pages
from frequencies import *


alphabet = {
	"lowercase": u"abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": u"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

alphabetpattern = "[%s]" % "|".join(list(alphabet["lowercase"]))

def process_page_text(base, text):
	m = re.search(r'le\:(fr.*)$', base, re.UNICODE)
	if m:
		print m.group(1)
		print text
		filename_out = "/data/wikidumps/templates/%s" % m.group(1)
		with open(filename_out, "w") as f_out:
			f_out.write(text.encode('utf8'))
			f_out.flush()

parse_pages('/data/wikidumps/frwiktionary-templates.xml', process_page_text)


#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
from pprint import PrettyPrinter
import re
from pymongo import MongoClient
from scraperutils import *

dumper = PrettyPrinter(indent=4, depth=6)

alphabet = {
	"lowercase": "abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

invalidcharpattern = "\"|\(|\)|\[|\]|\{|\}|\<|\>|!|&|?|%|+|:|;«»"

language_code = 'fr'

# Connect to the DB
db = DBConnect()

def Main():
	db.phrase_counts.remove({
		'lang': language_code,
	})

	parse_pages("/data/wikidumps/frwiki-latest-pages-articles1.xml",
		max_pages      = None,
		process_text_f = process_text,
		show_progress  = True)


def process_text(base, pageid, text):
	# Get mostly complete sentences on which to analyze vocabulary
	sentences = _GetSentences(text)

	phrasehash = {}

	# Get the words
	for sentence in sentences:
		_AnalyzeSentence(sentence, phrasehash)

	if phrasehash: _InsertWordCounts(phrasehash, pageid)


def _GetSentences(text) :
	# Get sentences
	sentences = [x for x in text.split(".") if not re.search(r'\n', x)]
	processed = []
	for sentence in sentences :

		# Clean up ends
		sentence = sentence.strip()

		# Skip malformed sentences
		if not re.search("^[%s]" % "|".join(list(alphabet["uppercase"])), sentence): continue
		if re.search("^\|", sentence): continue
		# Get rid of links
		sentence = re.sub(r"\[\[(.+?)\]\]", r"\1" , sentence)

		processed.append(sentence)

	return processed


def _AnalyzeSentence(text, phrasehash) :
	words = text.split(" ")
	
	for phraselength in range(1, 6) :
		phrasewords = []
		for word in words:
			phrasewords.append(word)
			if len(phrasewords) > phraselength:
				phrasewords = phrasewords[1:phraselength+1]
			if len(phrasewords) == phraselength:
				# Construct the phrase by joining words with spaces and polishing it
				phrase = " ".join(phrasewords)
				re.sub(r"^([%s])" % invalidcharpattern, r"\1", phrase)
				re.sub(r"([%s])$" % invalidcharpattern, r"\1", phrase)
				phrase = phrase.replace(u"\u2018", "'").replace(u"\u2019", "'").replace(u"\u201c","\"").replace(u"\u201d", "\"")
				phrase = phrase.lower().strip('\'\"-,.:;!?')

				# Valdidate the phrase
				if re.search(r"[%s]" % invalidcharpattern, phrase): continue
				if re.search(r"[0-9]", phrase): continue
				if re.search(r"''", phrase): continue

				# If validation passed, increment the phrase count for this phrase
				try: 
					phrasehash[phrase]["count"] += 1
				except:
					phrasehash[phrase] = {
						"phraselength": phraselength,
						"count"       : 1,
					}
	

def _InsertPageMetadata(pageid, pagetitle) :
	pass

def _InsertWordCounts(phrasehash, pageid) :

	obj = {}
	for phrase in phrasehash.keys():
		phraselength = "%s" % phrasehash[phrase]["phraselength"]
		count        = phrasehash[phrase]["count"]

		if count >= 2:
			if phraselength not in obj:
				obj[phraselength] = {}
			obj[phraselength][phrase] = phrasehash[phrase]["count"]

	# Perform the bulk insert
	try:
		db.phrase_counts.insert({
			"lang"  : language_code,
			"counts": obj,
		})
	except:
		print "A document failed to insert"


Main()
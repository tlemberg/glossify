#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import dbutils
import re
import scraper
import sys

from xml.etree.ElementTree import iterparse

invalidcharpattern = r"\"|\(|\)|\[|\]|\{|\}|\<|\>|!|&|\?|%|\+|:|;|«|»|=|\*|#|\n|\.|@|\$|\\|~|\_"

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("lang")
parser.add_argument("path")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = dbutils.DBConnect()

# Get langauge hash
language_info_hash = scraper.get_iso_codes_hash()[args.lang]


################################################################################
# Main
#
################################################################################
def Main():
	db.phrase_counts.remove({
		'lang': args.lang,
	})

	xml_file = args.path

	scraper.parse_pages(db,
		xml_file       = xml_file,
		max_pages      = 5000,
		process_text_f = process_text,
		show_progress  = True)


################################################################################
# process_text
#
################################################################################
def process_text(base, pageid, text):
	if text == None:
		return

	# Get mostly complete sentences on which to analyze vocabulary
	phrasehash = {}
	"""
	sentences = _GetSentences(text)

	

	# Get the words
	for sentence in sentences:
		_AnalyzeSentence(sentence, phrasehash)
	"""

	_analyzeText(text, phrasehash)

	if phrasehash: _InsertWordCounts(phrasehash, pageid)


"""
################################################################################
# _GetSentences
#
################################################################################
def _GetSentences(text) :
	# Get sentences
	sentences = [x for x in text.split(".") if not re.search(r'\n', x)]
	processed = []
	for sentence in sentences :

		# Clean up ends
		sentence = sentence.strip()

		# Skip malformed sentences
		# if not re.search("^[%s]" % "|".join(list(alphabet["uppercase"])), sentence): continue
		if re.search("^\|", sentence): continue
		# Get rid of links
		sentence = re.sub(r"\[\[(.+?)\]\]", r"\1" , sentence)

		processed.append(sentence)

	return processed
"""


################################################################################
# _analyzeText
#
################################################################################
def _analyzeText(text, phrasehash) :
	words = None
	if 'noSpacing' in language_info_hash:
		words = text.split('')
	else:
		words = text.split(' ')
	
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
				if phrase == '': continue
				if phrase.count(' ') == len(phrase): continue

				# If validation passed, increment the phrase count for this phrase
				try: 
					phrasehash[phrase]["count"] += 1
				except:
					phrasehash[phrase] = {
						"phraselength": phraselength,
						"count"       : 1,
					}
	

################################################################################
# _InsertPageMetadata
#
################################################################################
def _InsertPageMetadata(pageid, pagetitle) :
	pass


################################################################################
# _InsertWordCounts
#
################################################################################
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
			"lang"  : args.lang,
			"counts": obj,
		})
	except:
		print obj
		print "A document failed to insert", sys.exc_info()[0]


Main()

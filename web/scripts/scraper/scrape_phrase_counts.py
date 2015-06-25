#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import dbutils
import re
import scraper
import sys
import io

from xml.etree.ElementTree import iterparse
from datetime import datetime

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

total_count = 0


################################################################################
# Main
#
################################################################################
def Main():
	db.phrase_counts.remove({
		'lang': args.lang,
	})

	xml_file = args.path #io.open(args.path, encoding='utf-8', errors='replace')

	print ""

	scraper.parse_pages(db,
		xml_file       = xml_file,
		max_pages      = 100000,
		process_text_f = process_text,
		show_progress  = False)

	global total_count
	print "Total count: %s" % total_count


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


	t0 = datetime.now()
	_analyzeText(text, phrasehash)
	t1 = datetime.now()
	#print "  analyze: ", (t1-t0)

	global total_count

	if phrasehash:
		_InsertWordCounts(phrasehash, pageid)
		total_count += len(phrasehash.keys())
		print "\r", "{0:.2f}".format(100. * float(total_count) / 100000000), '%',

	if total_count >= 100000000:
		print "Reached 100000000 phrases"
		sys.exit()


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
	lRange = None
	noAscii = False
	noSpacing = False
	if args.lang in ['zh', 'th', 'ko', 'ja']:
		words = text
		noAscii = True
		noSpacing = True
	else:
		words = text.split(' ')
	if args.lang in ['zh', 'th', 'ko', 'ja', 'ar']:
		noAscii = True

	if args.lang in ['zh']:
		lRange = range(1, 5)
	elif args.lang in ['th']:
		lRange = range(1, 8)
	elif args.lang in ['ja']:
		lRange = range(1, 8)
	elif args.lang in ['ko']:
		lRange = range(1, 6)
	else:
		lRange =range(1, 3)
	
	for phraselength in lRange :
		phrasewords = []
		for word in words:
			phrasewords.append(word)
			if len(phrasewords) > phraselength:
				phrasewords = phrasewords[1:phraselength+1]
			if len(phrasewords) == phraselength:
				# Construct the phrase by joining words with spaces and polishing it
				phrase = None
				if noSpacing:
					phrase = "".join(phrasewords)
				else:
					phrase = " ".join(phrasewords)
				#re.sub(r"^([%s])" % invalidcharpattern, r"\1", phrase)
				#re.sub(r"([%s])$" % invalidcharpattern, r"\1", phrase)
				phrase = phrase.replace(u"\u2018", "'").replace(u"\u2019", "'").replace(u"\u201c","\"").replace(u"\u201d", "\"")
				phrase = phrase.lower().strip('\'\"-,.:;!?')

				# Valdidate the phrase
				if re.search(r"[%s]" % invalidcharpattern, phrase): continue
				if re.search(r"[0-9]", phrase): continue
				if re.search(r"''", phrase): continue
				if phrase == '': continue
				if phrase.count(' ') == len(phrase): continue

				if noAscii:
					if re.search(r'[A-Za-z]', phrase): continue

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
		t0 = datetime.now()
		db.phrase_counts.insert({
			"lang"  : args.lang,
			"counts": obj,
			"pageid": pageid,
		})
		t1 = datetime.now()
		#print "  insert: ", (t1-t0)
	except:
		#print obj
		print "A document failed to insert", sys.exc_info()[0]


Main()

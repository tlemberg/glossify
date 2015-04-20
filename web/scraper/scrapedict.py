#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import parse_pages, hashify
from frequencies import *


alphabet = {
	"lowercase": u"abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": u"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

abc = "[%s]" % "|".join(list(alphabet["lowercase"]))


hashes = {}
alternates = []


# Get the phrases we want to define
db = DBConnect()
validphrases = GetPhrases(db, phraselength=1)

def Main() :
	parse_pages('/data/wikidumps/frwiktionary-filtered.xml', hashify(validphrases), process_page_text)
	new_alternates = [x for x in alternates if x not in validphrases]
	parse_pages('/data/wikidumps/frwiktionary-filtered.xml', hashify(new_alternates), process_page_text)


def insert_info_hash(base, info):
	if base not in hashes:
		hashes[base] = {
			"text": base,
			"lang": "fr",
			"entries": [],
		}

	hashes[base]["entries"].append(info)
	#print info


def process_nom(base, lines):

	info = {}

	# Get the form code for this base word
	morphology_line = lines[0]
	m = re.search(ur'^\{\{(.*)\|', morphology_line, re.UNICODE)
	if m:
		info["form_code"] = m.group(1)
	
	# Get the gender of the base word
	gender_line = lines[1]
	m = re.search(r'\{\{([m|f])\}\}', gender_line)
	if m:
		info["gender"] = m.group(1)

	insert_info_hash(base, info)


def process_verbe(base, lines):

	# Check if this is a form of another word
	form_line = lines[0]
	m = re.search(r'fr-verbe-flexion.*\|(%s+?)(\||\})' % abc, form_line, re.UNICODE)
	if m:
		alternates.append(m.group(1))
		return

	# Actually process
	print base


def process_page_text(base, text):

	info = None
	hashes = {}

	parse_text(base, text, {
		"nom": process_nom,
		"verbe": process_verbe
	})


def _AnalyzeText(text, base) :
	# Event system
	ondeck = None
	atbat  = None
	info = None

	hashes = {}
	for line in text.split("\n") :
		# Update event trackers
		atbat  = ondeck
		ondeck = None

		# Handle queued events

		if info != None and info["function"] == "nom" :
			if atbat == "morphology" :
				info["forms"] = _AnalyzeMorphology(line, base, info["function"])
				ondeck = "gender"
				genderattempts = 0
			elif atbat == "gender" :
				info["gender"] = _AnalyzeGender(line)
				genderattempts += 1
				if genderattempts < 2 and not info["gender"] :
					ondeck = "gender"
		if info != None and info["function"] == "adjectif" :
			if atbat == "morphology" :
				info["forms"] = _AnalyzeMorphology(line, base, info["function"])
		if info != None and info["function"] == "verbe" :
			if atbat == "conjugation" :
				relatedword = _AnalyzeRelatedWord(line, base)
				if relatedword :
					info["relatedword"] = relatedword
					break
				else :
					info["conjugation"] = _AnalyzeConjugation(line, base)

		# Look for events
		if re.search(r'\{\{S\|([a-z]+)\|fr[\}|\|]', line) :
			info = { "base": base }
			if base not in hashes:
				hashes[base] = {
					"text": base,
					"lang": "fr",
					"entries": [],
				}

			hashes[base]["entries"].append(info)

			# Get the function of the word (nom, verbe, etc.)
			info["function"] = _AnalyzeFunction(line)

			# If the function is "nom", then get the morphology
			if info["function"] == "nom" :
				ondeck = "morphology"
			elif info["function"] == "adjectif" :
				ondeck = "morphology"
			# If the function is "verbe", determine the conjugation
			elif info["function"] == "verbe" :
				ondeck = "conjugation"
			elif info["function"] == "adverbe" :
				info["forms"] = {"standard": base}
			elif info["function"] == "conjonction" :
				info["forms"] = {"standard": base}
			elif info["function"] == "interjection" :
				info["forms"] = {"standard": base}

	if hashes:
		#print hashes.values()
		_InsertHashes(hashes.values())


def _AnalyzeFunction(line) :
	m = re.search(r'\{\{S\|([a-z]+)\|fr', line)
	if m:
		return m.group(1)


def _AnalyzeGender(line) :
	m = re.search(r'\{\{([m|f])\}\}', line)
	if m:
		return m.group(1)


def _AnalyzeMorphology(line, base, function) :
	if function == "nom":
		if re.search(ur'^\{\{fr-rég', line, re.UNICODE) :
			# Regular morphology
			return {
				"s": base,
				"p": "%ss" % base,
			}
	elif function == "adjectif":
		print "adjectif morph"
		if re.search(ur'^\{\{fr-rég', line, re.UNICODE) :
			# Regular morphology
			return {
				"s": base,
				"p": "%ss" % base,
			}



def _AnalyzeRelatedWord(line, base) :
	m = re.search(r"^\{\{fr-verbe-flexion\|(%s+)\|" % alphabetpattern, line, re.UNICODE)
	if m:
		return m.group(1)


def _AnalyzeConjugation(line, base) :		
	m = re.search(r'\{\{conjugaison\|fr\|grp=([0-9])\}\}', line, re.UNICODE)
	if m:
		return m.group(1)


def _InsertHashes(hashes) :
	client = MongoClient('localhost', 27017)
	db = client.tenk

	# Remove existing entries
	db.phrases.remove({ "text": {"$in": [ x["text"] for x in hashes ]} })

	# Insert all of the new entries
	db.phrases.insert(hashes)


Main()
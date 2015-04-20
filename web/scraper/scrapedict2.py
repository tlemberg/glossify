#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree.ElementTree import iterparse
import re
from pymongo import MongoClient
from scraperutils import *
from frequencies import *


alphabet = {
	"lowercase": u"abcdebghijklmnopqrstuvwxyzàâæäçéèêëîïôœöùûüÿ",
	"uppercase": u"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÄÇÉÈÊËÎÏÔŒÖÙÛÜŸ",
}

alphabetpattern = "[%s]" % "|".join(list(alphabet["lowercase"]))


def Main() :
	npagesparsed = 0

	# Get the phrases we want to define
	db = DBConnect()
	validphrases = GetPhrasesAsHash(db, phraselength=1)

	context = iterparse("/data/wikidumps/frwiktionary-filtered-small.xml", events=("start", "end"))
	context = iter(context)
	event, root = context.next()

	for (event, elem) in context:
		if event == "end":
			if re.search(r'page$', elem.tag) :
				_ParsePage(validphrases, elem)
				npagesparsed += 1
			root.clear()
			#if npagesparsed >= 1000: break

	print npagesparsed


def _ParsePage(validphrases, page) :

	base = None

	# Get the metadate for the page
	for elem in list(page):
		if re.search(r'id$', elem.tag) :
			pageid = elem.text
		elif re.search(r'title$', elem.tag) :
			base = elem.text

	# Determine if we want to scrape this base phrase
	if not base or base not in validphrases: return

	# Find the text of the page and analyze it
	for elem in list(page):
		if re.search(r'revision$', elem.tag) :
			for elem in list(elem):
				if re.search(r'text$', elem.tag) :
					info = _AnalyzeText(elem.text, base)


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
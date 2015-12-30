# -*- coding: utf-8 -*-
import re
from app.appconfig     import app_instance, mongo

def segment_doc(text, lang):
	text = text.replace('\n', ' ').replace('\t', '');
	# Non greek full stops
	full_stop = {
		'zh' : u'。',
		'jp' : u'。'
	}
	if lang in full_stop.keys():
		return text.split(full_stop[lang])
	# For all greet languages, split on one-word stop to avoid abbr periods.
	return text.split('. ')

def excerpt_to_phrase_ids(text, lang, known_phrases):
	coll = mongo.db["phrases_%s" % lang]
	phrase_id_map = {}
	if lang == 'zh':
		# for chinese, interested in multi-character phrases
		for phrase_size in xrange(1,5):
			for i in xrange(0, len(text)-phrase_size+1):
				j = i + phrase_size
				phrase = text[i:j]
				phrase_id = coll.find_one({'base': phrase, 'txs': {'$exists': 1}}, {'_id': 1})
				if phrase_id:
					phrase_id_map[phrase] = phrase_id['_id']
		# if a character is in a phrase, then remove character definition
		for phrase in phrase_id_map.keys():
			if len(phrase) > 1:
				for c in phrase:
					if c in phrase_id_map:
						del phrase_id_map[c]
	else:
		for phrase in text.split(' '):
			norm_phrase = normalize(phrase, lang)
			phrase_id_map[norm_phrase] = None
			if norm_phrase not in known_phrases:
				phrase_id = coll.find_one({'base': norm_phrase, 'txs': {'$exists': 1}}, {'_id': 1})
				if phrase_id:
					phrase_id_map[norm_phrase] = phrase_id['_id']
			else: phrase_id_map[norm_phrase] = known_phrases[norm_phrase]
	return phrase_id_map

def normalize(word, lang):
	# currently ignoring language
	# return word.lower().strip(':').strip('"').strip('.').strip(',').strip('-')

	# Use Regex
	lower_word = word.lower()
	pattern=re.compile(u'[^\w+\']', re.UNICODE)
	return pattern.sub('', lower_word, re.UNICODE)

	# return word # Without normalization, average hit rate is <10% lower
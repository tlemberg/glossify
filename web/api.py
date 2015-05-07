from flask import Flask
from flask import render_template
from flask.ext.pymongo import PyMongo
from flask import request, redirect

from operator import attrgetter
from models.phrases import get_total_phrase_counts

from bson.objectid import ObjectId
import json

from utils import app, api, mongo, json_result

from auth import verify_auth_token


################################################################################
# add_language
#
################################################################################
@app.route('/api/add-language/<lang>')
def add_language(lang):
	user_profile = verify_auth_token()
	if not user_profile:
		return json_result({
			'success': 0,
			'error'  : 'user not found or is not confirmed',
		})

	if user_profile is not None:
		email = user_profile['email']
		if lang not in user_profile['langs']:
			user_profile['langs'][lang] = generate_empty_language(lang)
			mongo.db.user_profiles.update(
				{ 'email': email },
				user_profile,
				upsert = True,
			)
			return json_result({
				'success': 1,
			})
		else:
			return json_result({
				'success': 0,
				'error'  : "user %s already has language %s" % (email, lang),
			})
	else:
		return json_result({
			'success': 0,
			'error'  : 'user not found',
		})


################################################################################
# generate_empty_language
#
################################################################################
def generate_empty_language(lang):
	# Create the progress hash
	phrases = []
	for phrase in mongo.db.phrases.find({ 'lang': lang }).sort('rank', 1):
		phrases.append({
			'phrase_id': phrase['_id'],
			'progress' : 0,
		})
	return phrases


################################################################################
# get_dictionary
#
################################################################################
@app.route('/api/get-dictionary/<lang>')
def get_dictionary(lang):
	return render_template("dictionaries/%s.json" % lang)

	
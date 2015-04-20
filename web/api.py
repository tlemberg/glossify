from flask import Flask
from flask import render_template
from flask.ext.pymongo import PyMongo
from flask import request, redirect

from operator import attrgetter
from models.phrases import get_total_phrase_counts

from bson.objectid import ObjectId
import json

from utils import app, api, mongo, json_result

from flask.ext.security import auth_token_required


@app.route('/api/add-language/<email>/<lang>')
@auth_token_required
def add_language(email, lang):
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })
	if user_profile is not None:
		if lang not in user_profile['langs']:
			user_profile['langs'][lang] = generate_empty_language(lang)
			mongo.db.user_profiles.update({ 'email': email }, user_profile)
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


def generate_empty_language(lang):
	# Create the progress hash
	i = 0
	tiles = []
	tile = None
	for phrase in mongo.db.phrases.find({ 'lang': lang }).sort('rank', 1):
		if i == 0:
			if tile is not None:
				tiles.append(tile)
			tile = []
		tile.append({
			'phrase_id': phrase['_id'],
			'progress' : 0,
		})
		i = (i + 1) % 25
	return tiles


@app.route('/api/get-dictionary/<lang>')
@auth_token_required
def get_dictionary(lang):
	return render_template("dictionaries/%s.json" % lang)

	
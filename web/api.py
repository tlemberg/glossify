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
# get_dictionary
#
################################################################################
@app.route('/api/get-dictionary/<lang>')
def get_dictionary(lang):

	# Authenticate the user
	user_profile = verify_auth_token()
	if not user_profile:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	# Return success
	return render_template("dictionaries/%s.json" % lang)


################################################################################
# get_plan
#
################################################################################
@app.route('/api/get-plan', methods=['POST'])
def get_plan():
	# Authenticate the user
	user_profile = verify_auth_token()
	if user_profile is None:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	try:
		# Read the parameters
		lang = request.form['lang']
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	# Create the plan array
	plan = []
	for phrase in mongo.db.phrases.find({ 'lang': lang }, { '_id': 1 }).sort('rank', 1):
		plan.append( phrase['_id'] )

	# Return success
	return json_result({
		'success': 1,
		'result' : plan,
	})


################################################################################
# add_language
#
################################################################################
@app.route('/api/add-language', methods=['POST'])
def add_language(lang):
	
	# Authenticate the user
	user_profile = verify_auth_token()
	if not user_profile:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	# Get user properties
	email = user_profile['email']

	try:
		# Read the parameters
		lang = request.form['lang']
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})
		
	if lang not in user_profile['langs']:
		# Append the language to the array
		user_profile['langs'].append(lang)

		# Perform the upsert
		mongo.db.user_profiles.update(
			{ 'email': email },
			user_profile,
			upsert = True,
		)

	# Return success
	return json_result({
		'success': 1,
	})


################################################################################
# get_progress
#
################################################################################
@app.route('/api/get-progress', methods=['POST'])
def get_progress():

	# Authenticate the user
	user_profile = verify_auth_token()
	if user_profile is None:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	# Get user properties
	email = user_profile['email']

	try:
		# Read the parameters
		lang = request.form['lang']
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	# Get user progress, or initialize an empty progress history if none exists
	user_progress = mongo.db.user_progress.find_one({ 'email': email, 'lang': lang })
	if user_progress == None:
		user_progress = {
			'email'   : email,
			'lang'	: lang,
			'progress': {},
		}
		mongo.db.user_progress.insert(user_progress)

	# Return success
	return json_result({
		'success': 1,
		'result' : user_progress,
	})


################################################################################
# update_progress
#
################################################################################
@app.route('/api/update-progress', methods=['POST'])
def update_progress():

	# Authenticate the user
	user_profile = verify_auth_token()
	if user_profile is None:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	# Get user properties
	email = user_profile['email']

	try:
		# Read the parameters
		card_updates_json = request.form['card_updates']
		lang			  = request.form['lang']

		# Decode JSON parameter
		card_updates = json.loads(card_updates_json)
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	# Get user progress, or initialize an empty progress history if none exists
	user_progress = mongo.db.user_progress.find_one({ 'email': email, 'lang': lang })
	if user_progress == None:
		user_progress = {
			'email'   : email,
			'lang'	: lang,
			'progress': {},
		}
		mongo.db.user_progress.insert(user_progress)

	# Iterate over the phrase ids and the new progress values, altering values
	for phrase_id, progress in card_updates.iteritems():
		user_progress['progress'][phrase_id] = progress

	# Perform the upsert
	mongo.db.user_progress.update(
		{ 'email': email, 'lang': lang },
		user_progress,
		upsert = True
	)

	# Return success
	return json_result({
		'success': 1,
	})

	
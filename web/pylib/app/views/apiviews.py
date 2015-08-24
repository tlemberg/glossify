from flask             import render_template, request, redirect, send_from_directory
from flask.ext.pymongo import PyMongo

from app.appconfig     import app_instance, mongo
from app.utils         import json_result

from auth              import verify_auth_token

import app.appconfig
import json
import os.path

from bson import ObjectId
import dictionary


################################################################################
# get_worksheet
#
################################################################################
@app.appconfig.app_instance.route('/api/get-worksheet/<name>')
def get_worksheet(name):
	return send_from_directory(os.path.join(app.appconfig.template_folder, 'worksheets'), "%s.csv" % name)


################################################################################
# get_dictionary
#
################################################################################
@app.appconfig.app_instance.route('/api/get-dictionary/<lang>')
def get_dictionary(lang):

	# Authenticate the user
	user_profile = verify_auth_token()
	if not user_profile:
		return json_result({
			'success': 0,
			'error'  : 'authentication failed',
		})

	# Return success
	return send_from_directory(os.path.join(app.appconfig.template_folder, 'dictionaries'), "%s.json" % lang)


################################################################################
# get_plan
#
################################################################################
@app.appconfig.app_instance.route('/api/get-plan', methods=['POST'])
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
		planMode = request.form['plan_mode']
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	# Create the plan array
	plan = []
	if planMode == 'frequency':
		coll = mongo.db["phrases_%s" % lang]
		for phrase in coll.find({ 'in_plan': 1 }, { '_id': 1 }).sort('rank', 1):
			plan.append( phrase['_id'] )
	else:
		email = user_profile['email']
		excerpts = mongo.db.excerpts.find({
			'lang': lang,
			'email': email })
		coll = mongo.db["phrases_%s" % lang]
		for e in excerpts:
			phrases = coll.find({ '_id': { '$in': e['phrase_ids'] } })
			plan.append({
				'deckId': e['_id'],
				'excerpt': e['excerpt'], 
				'phraseIds': [p['_id'] for p in phrases],
			})

	# Return success
	return json_result({
		'success': 1,
		'result' : plan,
	})


################################################################################
# add_language
#
################################################################################
@app.appconfig.app_instance.route('/api/add-language/<lang>', methods=['POST'])
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

	print lang
	print user_profile['langs']
		
	if lang not in user_profile['langs']:
		# Append the language to the array
		user_profile['langs'].append(lang)

		user_profile['langs'] = f7(user_profile['langs'])

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
@app.appconfig.app_instance.route('/api/get-progress', methods=['POST'])
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
			'progress': {
				'defs': { },
				'pron': { },
			},
		}
		mongo.db.user_progress.insert(user_progress)

	# Return success
	return json_result({
		'success': 1,
		'result' : user_progress,
	})


################################################################################
# add_Excerpt
#
################################################################################
@app.appconfig.app_instance.route('/api/add-excerpt', methods=['POST'])
def add_excerpt():

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
		excerpt = request.form['excerpt']
		lang = request.form['lang']
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	phrase_ids = []
	coll = mongo.db["phrases_%s" % lang]

	for phrase_size in xrange(1,5):
		for i in xrange(0, len(excerpt)-phrase_size+1):
			j = i + phrase_size
			phrase = excerpt[i:j]
			phrase_id = coll.find_one({'base': phrase, 'txs': {'$exists': 1}}, {'_id': 1})
			if phrase_id:
				phrase_ids.append(phrase_id['_id'])

	excerpt_id = mongo.db.excerpts.insert({
		'email': email,
		'lang': lang,
		'excerpt': excerpt,
		'phrase_ids': phrase_ids })

	# Return success
	return json_result({
		'success': 1,
		'result': excerpt_id })


################################################################################
# add_Excerpt
#
################################################################################
@app.appconfig.app_instance.route('/api/get-excerpt-dictionary', methods=['POST'])
def get_excerpt_dictionary():

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

	email = user_profile['email']

	excerpts = mongo.db.excerpts.find({
		'lang': lang,
		'email': email })

	phrase_ids = []
	for excerpt in excerpts:
		phrase_ids += excerpt['phrase_ids']

	print len(set(phrase_ids))

	coll = mongo.db["phrases_%s" % lang]

	cursor = coll.find({ '_id': { '$in': phrase_ids } })
	d = dictionary.create_dictionary_from_cursor(lang, cursor)

	print len(set(d.keys()))

	return json_result({
		'success': 1,
		'result' : d,
	})


################################################################################
# update_progress
#
################################################################################
@app.appconfig.app_instance.route('/api/update-progress', methods=['POST'])
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
		card_updates_json = request.form['progress_updates']
		deck_updates_json = request.form['deck_updates']
		lang			  = request.form['lang']

		# Decode JSON parameter
		card_updates = json.loads(card_updates_json)
		deck_updates = json.loads(deck_updates_json)
	except KeyError:
		# Return failure if the arguments don't exist
		return json_result({
			'success': 0,
			'error'  : 'invalid parameters',
		})

	if deck_updates != {}:
		for deck_id, phrase_ids in deck_updates.iteritems():
			deck = mongo.db.excerpts.update(
				{ '_id': ObjectId(deck_id) },
				{ '$set': { 'phrase_ids': [ObjectId(p) for p in phrase_ids] } },
			)

	if card_updates != {}:

		# Get user progress, or initialize an empty progress history if none exists
		user_progress = mongo.db.user_progress.find_one({ 'email': email, 'lang': lang })

		for studyMode in card_updates.keys():

			# Iterate over the phrase ids and the new progress values, altering values
			for phrase_id, progress in card_updates[studyMode].iteritems():
				user_progress['progress'][studyMode][phrase_id] = progress

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

	
def f7(seq, idfun=None): 
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       # in old Python versions:
       # if seen.has_key(marker)
       # but in new ones:
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result
from flask import Flask, url_for
from flask import render_template
from flask.ext.pymongo import PyMongo
from flask import request, redirect, jsonify


################################################################################
# record_page
#
################################################################################
@app.route('/crowd/record')
def record_page():

	# Get the ranks of phrases recorded by all users
	phrases = mongo.db.phrases.find(
		{
			'n_recordings': { '$lt': 3 },
		},
	).sort(
		{
			'rank': 1,
		},
	).limit(10)

	# Render the page
	return render_template('record.html',
		phrases = phrases,
	)


################################################################################
# verify_page
#
################################################################################
@app.route('/crowd/verify')
def verify_page():
	
	# Get the ranks of phrases recorded by all users
	phrases = mongo.db.phrases.find(
		{
			'n_verifications': { '$lt': 2 },
		},
	).sort(
		{
			'rank': 1,
		},
	).limit(10)

	# Render the page
	return render_template('verify.html',
		phrases = phrases,
	)


################################################################################
# correct_page
#
################################################################################
@app.route('/crowd/correct')
def correct_page():

	# Get the ranks of phrases recorded by all users
	phrases = mongo.db.phrases.find(
		{
			'n_corrections': 0,
		},
	).sort(
		{
			'rank': 1,
		},
	).limit(10)

	# Render the page
	return render_template('correct.html',
		phrases = phrases,
	)


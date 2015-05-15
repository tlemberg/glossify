from flask import Flask
from flask import render_template
from flask.ext.pymongo import PyMongo
from flask import request, redirect, jsonify

from operator import attrgetter
from models.phrases import get_total_phrase_counts

from bson.objectid import ObjectId
import json

from utils import app, mongo

@app.route('/')
def hello_world():
	
	# Pass the translation to the template
	return render_template('login.html')


@app.route('/phrases')
def phrases():

	total_phrase_counts = mongo.db.total_phrase_counts.find({ 'rank': { '$lt': 100 } })

	# Render the template by passing the total phrase counts
	return render_template('phrases.html',
		phrase_counts = total_phrase_counts,
	)


@app.route('/phrase/<base>', methods=['GET', 'POST'])
def phrase(base):

	# Get the phrase from the database
	phrase = mongo.db.phrases.find_one_or_404({
		'lang': 'fr',
		'base': base
	})

	if request.method == 'POST':
		# Apply changes from the form
		for k, txs in phrase['txs'].iteritems():
			for tx in txs:
				orig_rank = int(tx['rank'])
				tx['deleted'] = request.form["tx-deleted-%s-%d" % (k, orig_rank)] == '1'
				tx['text'] = request.form["tx-%s-%d" % (k, orig_rank)]
				tx['rank'] = int(request.form["tx-rank-%s-%d" % (k, orig_rank)])
			phrase['txs'][k] = sorted(txs, key=lambda tx: tx['rank'])

		# Perform the update
		mongo.db.phrases.update(
			{
			'lang': 'fr',
			'base': base
			},
			phrase
		)

	# Parse parameters
	show_deleted = int(request.args.get('show-deleted', 0))

	# Pass the translation to the template
	return render_template('phrase.html',
		phrase       = phrase,
		show_deleted = show_deleted
	)
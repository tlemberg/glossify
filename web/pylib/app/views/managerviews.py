import auth
import dbutils
import flask
import json
import manager

from app.appconfig import mongo, app_instance


################################################################################
# manage_page
#
################################################################################
@app_instance.route('/manage')
def manage_page():
	user_profile = auth.verify_auth_token()
	if user_profile == None:
		return flask.redirect(flask.url_for('login_page'))
	else:
		return flask.redirect(flask.url_for('phrases_page'))


################################################################################
# login_page
#
################################################################################
@app_instance.route('/manage/login', methods=['GET', 'POST'])
def login_page():

	if flask.request.method == 'POST':

		# Get form values
		email    = None
		password = None
		try:
			email    = flask.request.form['email']
			password = flask.request.form['password']
		except KeyError:
			pass

		# Attempt authentication
		if email and password:
			token = auth.store_auth_token_in_session(email, password)
			if token:
				return flask.redirect(flask.url_for('phrases_page'))
		

		# Handle failure
		return flask.render_template('login.html')

	else:
		return flask.render_template('login.html')


################################################################################
# home_page
#
################################################################################
@app_instance.route('/manage/home')
def home_page():

	# Authentication
	user_profile = auth.verify_auth_token()
	if user_profile == None:
		return flask.redirect(flask.url_for('unauthorized_page'))

	# Get permissions
	permissions = auth.get_permissions(user_profile)

	# Render the page
	if permissions == None:
		return flask.redirect(flask.url_for('unauthorized_page'))
	else:
		return flask.render_template('phrase.html',
			permissions = permissions,
		)


################################################################################
# phrases_page
#
################################################################################
@app_instance.route('/manage/phrases')
def phrases_page():

	# Authentication
	user_profile = auth.verify_auth_token()
	if user_profile == None or not auth.has_permission(user_profile, 'MANAGE_DICTIONARY'):
		return flask.redirect(flask.url_for('unauthorized_page'))

	min_phrase = flask.request.args.get('min-phrase')
	max_phrase = flask.request.args.get('max-phrase')
	if min_phrase and max_phrase:
		min_phrase = int(min_phrase)
		max_phrase = int(max_phrase)
	else:
		min_phrase = 0
		max_phrase = 99


	total_phrase_counts = mongo.db.total_phrase_counts.find({ 'rank': { '$gt': min_phrase-1, '$lt': max_phrase+1 } })

	processed_phrase_counts = []
	for phrase_count in total_phrase_counts:
		if dbutils.get_section_for_base(phrase_count['base']):
			phrase_count['has_section'] = 1
		if dbutils.get_phrase_for_base(phrase_count['base']):
			phrase_count['has_phrase'] = 1
		processed_phrase_counts.append(phrase_count)

	# Render the template by passing the total phrase counts
	return flask.render_template('phrases.html',
		min_phrase    = min_phrase,
		max_phrase    = max_phrase,
		phrase_counts = processed_phrase_counts,
	)


################################################################################
# phrase_page
#
################################################################################
@app_instance.route('/manage/phrase/<base>', methods=['GET', 'POST'])
def phrase_page(base):

	# Authentication
	user_profile = auth.verify_auth_token()
	if user_profile == None or not auth.has_permission(user_profile, 'MANAGE_DICTIONARY'):
		return flask.redirect(flask.url_for('unauthorized_page'))

	# Get the phrase from the database
	phrase = mongo.db.phrases.find_one({
		'lang': 'fr',
		'base': base
	})

	section = dbutils.get_section_for_base(base)

	if phrase and flask.request.method == 'POST':
		# Apply changes from the form
		for k, txs in phrase['txs'].iteritems():
			for tx in txs:
				orig_rank = int(tx['rank'])
				tx['deleted'] = flask.request.form["tx-deleted-%s-%d" % (k, orig_rank)] == '1'
				tx['text'] = flask.request.form["tx-%s-%d" % (k, orig_rank)]
				tx['rank'] = int(flask.request.form["tx-rank-%s-%d" % (k, orig_rank)])
			phrase['txs'][k] = sorted(txs, key=lambda tx: tx['rank'])

		# Perform the update
		mongo.db.phrases.update(
			{
			'lang': 'fr',
			'base': base
			},
			phrase,
		)

	# Parse parameters
	show_deleted = int(flask.request.args.get('show-deleted', 0))

	# Pass the translation to the template
	return flask.render_template('phrase.html',
		phrase       = phrase,
		section      = section,
		show_deleted = show_deleted
	)


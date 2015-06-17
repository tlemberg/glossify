import app.utils
import auth
import flask
import sys
import traceback

from app.appconfig import mongo, app_instance
from passlib.hash  import sha256_crypt


################################################################################
# unauthorized
#
################################################################################
@app_instance.route('/manage/unauthorized')
def unauthorized_page():
	# Pass the translation to the template
	return flask.render_template('unauthorized.html')


################################################################################
# get_auth_token
#
################################################################################
@app_instance.route('/api/authenticate-user', methods=['POST'])
def get_auth_token():

	# Extract params
	email	= flask.request.form['email']
	password = flask.request.form['password']

	# Find the user
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })

	# Return the result
	if user_profile is not None:
		if auth.verify_password(user_profile, password):
			token = auth.generate_auth_token(email)
			return app.utils.json_result({
				'success': 1,
				'result' : {
					'token'	  : token,
					'userProfile': user_profile,
				},
			})
		else:
			return app.utils.json_result({
				'success': 0,
				'error'  : 'email/password incorrect',
			})
	else:
		return app.utils.json_result({
			'success': 0,
			'error'  : 'user not found',
		})


################################################################################
# create_user
#
################################################################################
@app_instance.route('/api/create-user', methods=['POST'])
def create_user():
	# Extract params
	email	= flask.request.form['email']
	password = flask.request.form['password']

	# Do SQL work
	try:
		if auth.cerate_user_profile(mongo.db, email, password):

			auth.send_activation_email(email)
			
			return app.utils.json_result({
				'success': 1,
			})

		else:

			return app.utils.json_result({
				'success': 0,
				'error'  : 'user already exists with that email',
			})

	except:
		traceback.print_exc()
		return app.utils.json_result({
			'success': 0,
			'error'  : 'create user failed',
		})


################################################################################
# validate_user
#
################################################################################
@app_instance.route('/api/activate-user', methods=['GET'])
def activate_user():

	# Get the encoded message
	msg = flask.request.args.get('msg')

	# Get the serializer
	s = get_activation_serializer()

	# Attempt to retrieve the email from the encrypted message
	try:
		email = s.loads(msg)
	except BadSignature:
		abort(404)

	# Confirm the user
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })
	confirm_user_profile(user_profile)

	# Return success
	return flask.redirect("http://192.168.0.108:8000?action=activationsuccessful")


################################################################################
# request_access
#
################################################################################
@app_instance.route('/api/request-access', methods=['POST'])
def request_access():

	# Get the email of the potential user
	email = flask.request.form['email']

	# Send an email 
	auth.send_request_access_email(email)

	# Return success
	return app.utils.json_result({
		'success': 1,
	})



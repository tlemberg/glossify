import app.appconfig
import app.utils
import flask
import sys
import traceback


################################################################################
# unauthorized
#
################################################################################
@app.appconfig.app_instance.route('/manage/unauthorized')
def unauthorized_page():
	# Pass the translation to the template
	return flask.render_template('unauthorized.html')


################################################################################
# get_auth_token
#
################################################################################
@app.appconfig.app_instance.route('/api/authenticate-user', methods=['POST'])
def get_auth_token():

	# Extract params
	email	= flask.request.form['email']
	password = flask.request.form['password']

	# Find the user
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })

	# Return the result
	if user_profile is not None:
		if verify_password(user_profile, password):
			token = generate_auth_token(email)
			return app.utils.app.utils.json_result({
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
@app.appconfig.app_instance.route('/api/create-user', methods=['POST'])
def create_user():
	# Extract params
	email	= flask.request.form['email']
	password = flask.request.form['password']

	# Do SQL work
	try:
		password_hash = sha256_crypt.encrypt(password)

		# Check that no user already exists with that email
		if mongo.db.user_profiles.find_one({ 'email': email }) == None:

			mongo.db.user_profiles.insert({
				'email'	: email,
				'password' : password_hash,
				'active'   : 1,
				'confirmed': 0,
				'langs'	: {},
			})

			send_activation_email(email)
			
			return app.utils.json_result({
				'success': 1,
			})

		else:

			return app.utils.json_result({
				'success': 0,
				'error'  : 'user already exists with that email',
			})

	except:
		traceback.print_exc(file=sys.stdout)
		return app.utils.json_result({
			'success': 0,
			'error'  : 'create user failed',
		})


################################################################################
# validate_user
#
################################################################################
@app.appconfig.app_instance.route('/api/activate-user', methods=['GET'])
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



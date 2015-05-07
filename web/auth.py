from flask import Flask, render_template, request, url_for, redirect

from utils import app, mongo, json_result, mail, app_domain
import traceback, sys
from itsdangerous import URLSafeSerializer, BadSignature, SignatureExpired
from flask_mail import Message

from itsdangerous import TimedJSONWebSignatureSerializer as TimedSerializer
from passlib.hash import sha256_crypt


# Secret key
secret_key = '99cd44e7b746f9fa53613929e01855864b278981facd9f69'


################################################################################
# generate_auth_token
#
################################################################################
def generate_auth_token(email, expiration = 600):
	s = TimedSerializer(secret_key, expires_in = expiration)
	return s.dumps({ 'email': email })


################################################################################
# verify_auth_token
#
################################################################################
def verify_auth_token():

	# Extract GET parameters for authentication
	email = request.args.get('email')
	token = request.args.get('auth_token')

	s = TimedSerializer(secret_key)
	try:
		token_data = s.loads(token)
	except SignatureExpired:
		return None
	except BadSignature:
		return None

	email = token_data['email']
	user_profile = mongo.db.user_profiles.find_one({ 'email': email, 'confirmed': 1 })

	return user_profile


################################################################################
# verify_password
#
################################################################################
def verify_password(user_profile, password):

	# Extract the hash from the user_profile db object
	password_hash = user_profile['password']

	# Verify that the password supplied matches the retreived hash
	return sha256_crypt.verify(password, password_hash)


################################################################################
# get_auth_token
#
################################################################################
@app.route('/api/authenticate-user', methods=['POST'])
def get_auth_token():

	# Extract params
	email    = request.form['email']
	password = request.form['password']

	# Find the user
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })

	# Return the result
	if user_profile is not None:
		if user_profile['confirmed']:
			if verify_password(user_profile, password):
				token = generate_auth_token(email)
				return json_result({
					'success': 1,
					'result' : {
						'token'      : token,
						'userProfile': user_profile,
					},
				})
			else:
				return json_result({
					'success': 0,
					'error'  : 'email/password incorrect',
				})
		else:
			return json_result({
				'success': 0,
				'error'  : 'user not yet activated',
			})
	else:
		return json_result({
			'success': 0,
			'error'  : 'user not found',
		})


################################################################################
# create_user
#
################################################################################
@app.route('/api/create-user', methods=['POST'])
def create_user():
	# Extract params
	email    = request.form['email']
	password = request.form['password']

	# Do SQL work
	try:
		password_hash = sha256_crypt.encrypt(password)
		mongo.db.user_profiles.insert({
			'email'    : email,
			'password' : password_hash,
			'active'   : 1,
			'confirmed': 0,
		})

		send_activation_email(email)
		
		return json_result({
			'success': 1,
		})
	except:
		traceback.print_exc(file=sys.stdout)
		return json_result({
			'success': 0,
			'error'  : 'create user failed',
		})


################################################################################
# validate_user
#
################################################################################
def get_activation_serializer():
	return URLSafeSerializer('99cd44e7b746f9fa53613929e01855864b278981facd9f69')


################################################################################
# validate_user
#
################################################################################
@app.route('/api/activate-user', methods=['GET'])
def activate_user():

	# Get the encoded message
	msg = request.args.get('msg')

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
	return redirect("%s?action=activationsuccessful" % app_domain)


################################################################################
# send_activation_email
#
################################################################################
def send_activation_email(email):

	# Get an activation link
	s = get_activation_serializer()
	msg = s.dumps(email)
	activation_link = url_for('activate_user', msg=msg, _external=True)

	# Construct the email
	msg = Message("Activate your TenK account",
		sender     = "noreply@glossify.net",
		recipients = [email],
	)
	msg.html = "Click <a href='%s'>here</a> to activate your account." % activation_link
	
	# Send the email
	print msg
	# mail.send(msg)

################################################################################
# confirm_user_profile
#
################################################################################
def confirm_user_profile(user_profile):

	user_profile['confirmed'] = 1
	user_profile['langs'] = {}

	# Upsert the document
	mongo.db.user_profiles.update(
		{ 'email': user_profile['email'] },
		user_profile,
		upsert = True
	)


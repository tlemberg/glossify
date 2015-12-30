import app.utils
import boto.ses
import itsdangerous
import flask
import passlib.hash

from app.appconfig import mongo
from passlib.hash  import sha256_crypt


################################################################################
# secret_key
#
################################################################################
secret_key = '99cd44e7b746f9fa53613929e01855864b278981facd9f69'


################################################################################
# permissions
#
################################################################################
all_permissions = [
	'root',
	'manage_dictionary',
]


################################################################################
# generate_auth_token
#
################################################################################
def generate_auth_token(email):
	s = itsdangerous.JSONWebSignatureSerializer(secret_key)
	return s.dumps({ 'email': email })


################################################################################
# verify_auth_token
#
################################################################################
def verify_auth_token():

	# Get the token either from GET or from SESSION, or else return None
	token = flask.request.args.get('auth_token')
	if not token:
		try:
			token = flask.session['token']
		except KeyError:
			return

	s = itsdangerous.JSONWebSignatureSerializer(secret_key)
	try:
		token_data = s.loads(token)
	except itsdangerous.SignatureExpired:
		return None
	except itsdangerous.BadSignature:
		return None

	email = token_data['email']
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })

	return user_profile


################################################################################
# verify_password
#
################################################################################
def verify_password(user_profile, password):

	# Extract the hash from the user_profile db object
	password_hash = user_profile['password']

	# Verify that the password supplied matches the retreived hash
	return passlib.hash.sha256_crypt.verify(password, password_hash)


################################################################################
# store_auth_token_in_session
#
################################################################################
def store_auth_token_in_session(email, password):

	# Find the user
	user_profile = mongo.db.user_profiles.find_one({ 'email': email })

	print user_profile

	# Return the result
	if user_profile is not None:
		if verify_password(user_profile, password):
			token = generate_auth_token(email)
			flask.session['token'] = token
			return token


################################################################################
# create_user_profile
#
################################################################################
def create_user_profile(db, email, password, confirmed=0):
	password_hash = sha256_crypt.encrypt(password)

	# Check that no user already exists with that email
	if db.user_profiles.find_one({ 'email': email }) == None:

		db.user_profiles.insert({
			'email'	   : email,
			'password' : password_hash,
			'active'   : 1,
			'confirmed': confirmed,
			'langs'	   : [],
		})

		return True

	return None


################################################################################
# validate_user
#
################################################################################
def get_activation_serializer():
	return itsdangerous.URLSafeSerializer('99cd44e7b746f9fa53613929e01855864b278981facd9f69')


################################################################################
# send_activation_email
#
################################################################################
def send_activation_email(email):

	# Get an activation link
	s = get_activation_serializer()
	msg = s.dumps(email)
	activation_link = flask.url_for('activate_user', msg=msg, _external=True)

	conn = boto.ses.connect_to_region('us-west-2')
	conn.verify_email_address('noreply@glossify.io')
	conn.send_email(
		'noreply@glossify.io',
		'Activate your glossify account',
		'',
		[email],
		html_body="Click <a href='%s'>here</a> to activate your account." % activation_link,
	)


################################################################################
# send_request_access_email
#
################################################################################
def send_request_access_email(email):

	conn = boto.ses.connect_to_region('us-west-2')
	conn.send_email(
		'noreply@glossify.io',
		'A user has requested access to glossify.io',
		'',
		['tlemberg10@gmail.com'],
		html_body="The user's email address is: %s" % email,
	)


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
	

################################################################################
# get_permissions
#
################################################################################
def get_permissions(user_profile):
	if 'permissions' in user_profile:
		return user_profile['permissions']
	else:
		return None


################################################################################
# has_permission
#
################################################################################
def has_permission(user_profile, permission_name):
	print user_profile
	if 'permissions' in user_profile:
		permissions = user_profile['permissions']
		return 'root' in permissions or permission_name.lower() in permissions
	else:
		return False


from flask import Flask, render_template, request, url_for, redirect
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.security import Security, SQLAlchemyUserDatastore, \
	UserMixin, RoleMixin, login_required
from flask.ext.security.utils import verify_and_update_password

from utils import sql_db, app, mongo, json_result, mail
import traceback, sys
from itsdangerous import URLSafeSerializer, BadSignature
from flask_mail import Message


################################################################################
# Define models
#
################################################################################
roles_users = sql_db.Table('roles_users',
		sql_db.Column('user_id', sql_db.Integer(), sql_db.ForeignKey('user.id')),
		sql_db.Column('role_id', sql_db.Integer(), sql_db.ForeignKey('role.id')))

class Role(sql_db.Model, RoleMixin):
	id          = sql_db.Column(sql_db.Integer(), primary_key=True)
	name        = sql_db.Column(sql_db.String(80), unique=True)
	description = sql_db.Column(sql_db.String(255))

class User(sql_db.Model, UserMixin):
	id           = sql_db.Column(sql_db.Integer, primary_key=True)
	email        = sql_db.Column(sql_db.String(255), unique=True)
	password     = sql_db.Column(sql_db.String(255))
	active       = sql_db.Column(sql_db.Boolean())
	confirmed_at = sql_db.Column(sql_db.DateTime())
	roles        = sql_db.relationship('Role', secondary=roles_users,
							backref=sql_db.backref('users', lazy='dynamic'))


################################################################################
# Setup Flask-Security
#
################################################################################
user_datastore = SQLAlchemyUserDatastore(sql_db, User, Role)
security = Security(app, user_datastore)


################################################################################
# get_auth_token
#
################################################################################
@app.route('/api/authenticate-user', methods=['POST'])
def get_auth_token():
	# Extract params
	email    = request.form['email']
	password = request.form['password']

	# Query for the user
	user = user_datastore.get_user(email)

	# Return the result
	if user and verify_and_update_password(password, user):
		token = user.get_auth_token()
		user_profile = mongo.db.user_profiles.find_one({ 'email': email })
		if user_profile is not None:
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
				'error'  : 'user not found',
			})
	else:
		return json_result({
			'success': 0,
			'error'  : 'email/password incorrect',
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

	print "HELLLLO!\n"
	print email

	# Do SQL work
	sql_db.create_all()
	try:
		user_datastore.create_user(email=email, password=password)
		sql_db.session.commit()

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

	# Since the email exists, create a user profile
	create_user_profile(email)

	# Return success
	return redirect("/app?action=activationsuccessful")


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
		sender     = "noreply@tenk.com",
		recipients = [email],
	)
	msg.html = "Click <a href='%s'>here</a> to activate your account." % activation_link
	
	# Send the email
	print msg
	# mail.send(msg)

################################################################################
# create_user_profile
#
################################################################################
def create_user_profile(email):

	# Upsert the document
	mongo.db.user_profiles.remove({
		'email': email,
	})
	mongo.db.user_profiles.insert({
		'email': email,
		'langs': {},
	})


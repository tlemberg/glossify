import auth
import dbutils
import os
import os.path
import yaml

# Connect to the DB
db = dbutils.DBConnect()



yaml_file = os.path.join(os.environ['PROJECT_HOME'], 'web/permissions.yaml')
permissions_hash = yaml.load(open(yaml_file, 'r'))

for email, permissions in permissions_hash.iteritems():

	# Get the user_profile
	user_profile = db.user_profiles.find_one({
		'email': email,
	})

	# Errors
	if not user_profile:
		raise AssertionError("no user_profile with that email")

	for permission in permissions:
		if permission not in [p.lower() for p in auth.all_permissions]:
			raise AssertionError("no such permission")

	# Update permissions
	user_profile['permissions'] = permissions

	# Update the user_profile
	db.user_profiles.update(
		{
			'email': email,
		},
		user_profile,
	)


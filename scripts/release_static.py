import os
import csv

import boto

from boto.s3.key import Key


################################################################################
# main
#
################################################################################
def main():

	# Get security credentials and connect to S3
	creds =  get_aws_credentials()
	conn  = boto.connect_s3(creds['Access Key Id'], creds['Secret Access Key'])

	# Connect to the staticfiles bucket
	bucket = conn.get_bucket('glossify-staticfiles')

	k = Key(bucket)
	k.key = 'app'
	k.set_contents_from_filename("%s/app" % os.environ['PROJECT_HOME'])


################################################################################
# get_aws_credentials
#
################################################################################
def get_aws_credentials():
	with open("%s/config/credentials.csv" % os.environ['PROJECT_HOME']) as f:

		# Read the file
		lines = f.readlines()

		# Get keys and values
		keys   = [k.replace('"', '').strip() for k in lines[0].split(',')]
		values = [v.replace('"', '').strip() for v in lines[1].split(',')]

		# Construct a hash
		credentials = {}
		for i in range(0, len(keys)):
			credentials[keys[i]] = values[i]

		# Return the hash
		return credentials


if __name__ == "__main__":
	main()
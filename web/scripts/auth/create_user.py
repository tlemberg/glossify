import argparse
import auth
import dbutils

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("email")
parser.add_argument("password")

# Parse the arguments
args = parser.parse_args()

# Connect to DB
print "Connecting to DB"
db = dbutils.DBConnect('glossify.io', 'tlemberg', 'tlemberg')

auth.create_user_profile(db, args.email, args.password, confirmed=1)
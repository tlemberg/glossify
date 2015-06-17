import argparse
import auth
import dbutils

# Set up an arg parser
parser = argparse.ArgumentParser()
parser.add_argument("email")
parser.add_argument("password")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = dbutils.DBConnect()

auth.create_user_profile(db, args.email, args.password, confirmed=1)
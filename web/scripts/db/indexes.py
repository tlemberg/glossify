import dbutils
import pymongo

# Connect to the DB
db = dbutils.DBConnect()

db.phrases.create_index([
	('lang', pymongo.ASCENDING),
])

db.phrases.create_index([
	('lang', pymongo.ASCENDING),
	('rank', pymongo.ASCENDING),
])

db.phrases.create_index([
	('lang', pymongo.ASCENDING),
	('base', pymongo.ASCENDING),
])
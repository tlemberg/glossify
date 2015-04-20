from pymongo import MongoClient

client = MongoClient('localhost', 27017)
db = client.tenk

for doc in db.phrases.find():

	# Get the word
	base = doc['text']

	# Get the errors
	errors = []
	if 'entries' not in doc:
		errors.append("has no entries")
	for entry in doc['entries']:
		if 'forms' not in entry:
			errors.append("missing forms for function %s" % entry['function'])

	# Print the errors
	if errors:
		print base
		print "\t" + "\n\t".join(errors)
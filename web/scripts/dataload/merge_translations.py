import argparse
import dbutils, perf
import pymongo
from pprint import pprint

from tags import read_all_tag_files
from translations import translate
from word_lists import get_word_list


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('--host', default='glossify.io',
		help='server name where the database lives')
	parser.add_argument('--lang',
		help='2-character language code')
	args = parser.parse_args()

	# Connect to DB
	print "Connecting to DB"
	db = dbutils.DBConnect(args.host, 'tlemberg', 'tlemberg')
	forward_coll = db["word_list_%s_forward" % args.lang]
	reverse_coll = db["word_list_%s_reverse" % args.lang]
	phrases_coll = db["phrases_%s" % args.lang]

	# Removing items
	phrases_coll.remove({})

	# Get the words
	print "Iterating forward"
	buf = dbutils.DBWriteBuffer(phrases_coll)
	progress = perf.ProgressDisplay(forward_coll.count())
	for document in forward_coll.find():
		buf.append({
			'base': document['word'],
			'txs': [{
				'text': document['tx'],
			}],
			'count': document['count'],
		})
		progress.advance()
	buf.flush()

	# Ensure an index
	print "Indexing the 'base' field"
	phrases_coll.create_index([
		('base', pymongo.ASCENDING),
	])

	print "Iterating reverse"
	buf = dbutils.DBUpdateBuffer(phrases_coll)
	progress = perf.ProgressDisplay(reverse_coll.count())
	for document in reverse_coll.find():
		buf.append({
			'base': document['tx'],
		}, {
			'$addToSet': {
				'txs': {
					'text': document['word'],
				},
			},
			'$set': {
				'base': document['tx'],
				'count': document['count'],
			},
		}, upsert=True)
		progress.advance()
	buf.flush()

	# Ensure an index
	print "Indexing the 'count' field"
	phrases_coll.create_index([
		('count', pymongo.ASCENDING),
	])

	print "Setting ranks"
	buf = dbutils.DBUpdateBuffer(phrases_coll)
	progress = perf.ProgressDisplay(phrases_coll.count())
	rank = 1
	for document in phrases_coll.find():
		buf.append({
			'base': document['base'],
		}, {
			'$set': {
				'rank': rank,
			},
		}, upsert=True)
		rank += 1
		progress.advance()
	buf.flush()

	# Ensure an index
	print "Indexing the 'rank' field"
	phrases_coll.create_index([
		('rank', pymongo.ASCENDING),
	])

	# Add tags
	print "Adding tags"
	buf = dbutils.DBUpdateBuffer(phrases_coll)
	progress = perf.ProgressDisplay(phrases_coll.count())
	for document in phrases_coll.find():
		tags_to_add = set()
		for tag_name, tag_info in read_all_tag_files().iteritems():
			for tx in document['txs']:
				if tx['text'] in tag_info['phrases']:
					tags_to_add.add(tag_name)
					continue
		buf.append({
			'base': document['base'],
		}, {
			'$set': {
				'tags': list(tags_to_add),
			},
		}, upsert=True)
		progress.advance()
	buf.flush()



if __name__ == "__main__":
	main()

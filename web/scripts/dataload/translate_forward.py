import argparse, dbutils, perf, requests, time
from pprint import pprint

from translations import pooled_translate
from word_lists import get_word_list, print_pricing_info


MAX_FAILURES = 3


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('--host', default='glossify.io',
		help='server name where the database lives')
	parser.add_argument('--lang',
		help='2-character language code')
	parser.add_argument('--min-index', default=None, type=int,
		help='minimum word index')
	parser.add_argument('--max-index', default=None, type=int,
		help='maximum word index')
	parser.add_argument('--remove', action='store_true',
		help='remove all documents before beginning?')
	args = parser.parse_args()

	# Get the words
	print "Getting words"
	word_list = get_word_list(args.lang, min_index=args.min_index, max_index=args.max_index)
	print_pricing_info(word_list)

	# Connect to DB
	print "Connecting to DB"
	db = dbutils.DBConnect(args.host, 'tlemberg', 'tlemberg')
	coll_name = "word_list_%s_forward" % args.lang
	coll = db[coll_name]

	print "Removing documents"
	if args.remove:
		coll.remove({})

	print "Translating"
	buf = dbutils.DBWriteBuffer(coll)
	progress = perf.ProgressDisplay(len(word_list))
	for word_list_chunk in dbutils.chunk_list(word_list, 1000):
		n_failures = 0
		while n_failures < MAX_FAILURES:
			try:
				tx_dict = pooled_translate([tup[0] for tup in word_list_chunk], args.lang, 'en')
				break
			except requests.exceptions.SSLError as e:
				print "SSL Exception. Retrying."
				n_failures += 1
				if n_failures == MAX_FAILURES:
					raise Exception('Too many SSL Exceptions. Giving up.')
		for (word, count) in word_list_chunk:
			tx = tx_dict[word]
			buf.append({
				'word': word,
				'count': count,
				'tx': tx,
			})
			progress.advance(1)
	buf.flush()

	print "Done"




if __name__ == "__main__":
	main()

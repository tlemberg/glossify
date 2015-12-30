import os, zipfile


WORD_LISTS_BASE_PATH = os.environ.get('WORD_LISTS_BASE_PATH') or os.path.join(os.environ['PROJECT_HOME'], "word_lists")


def get_word_list_zip_path(lang):
	path = os.path.join(WORD_LISTS_BASE_PATH, "%s-2012.zip" % lang)
	try:
		open(path)
		return path
	except IOError:
		path = os.path.join(WORD_LISTS_BASE_PATH, "%s-2011.zip" % lang)
		return path


def get_word_list(lang, min_index=None, max_index=None):
	zip_path = get_word_list_zip_path(lang)
	with open(zip_path, 'rb') as f:
		z = zipfile.ZipFile(f)
		with z.open("%s.txt" % lang) as f:
			i = 0
			lines = []
			for line in f.readlines():
				line = line.strip().decode('utf-8')
				parts = line.split(' ')
				if not min_index or i >= min_index:
					lines.append((parts[0], int(parts[1])))
				i += 1
				if max_index and i >= max_index:
					return lines
			return lines


def print_pricing_info(word_list):
	total_chars = 0
	for word in word_list:
		print word[0], len(word[0])
		total_chars += len(word[0])
	price_dollars = float(total_chars) / 1000000. * 20.
	word_price_dollars = price_dollars / float(len(word_list))
	print "%d total characters in %d words" % (total_chars, len(word_list))
	print "$%.2f total cost, $%.5f per word on average" % (price_dollars, word_price_dollars)

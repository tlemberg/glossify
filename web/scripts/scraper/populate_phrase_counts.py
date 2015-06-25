import multiprocessing
import os
import os.path
import scraper
import yaml


################################################################################
# Script properties
#
################################################################################
parallel_level = 3
wikidumps_path = '/data/wikidumps'


################################################################################
# main
#
################################################################################
def main():

	# Get ISO codes
	iso_codes_hash    = scraper.get_iso_codes_hash()
	for k, v in iso_codes_hash.iteritems():
		v['isoCode'] = k
		iso_codes_hash[k] = v
	iso_language_hashes = sorted(iso_codes_hash.values(), key = lambda h: h['isoCode'])

	h = None
	good_h = []
	for h in iso_language_hashes:
		if h['isoCode'] in ['ja', 'de', 'th', 'ko']:
			good_h.append(h)
			

	# Create a pool and execute jobs
	#pool = multiprocessing.Pool(parallel_level)
	#pool.map(process_main, ['fr'])
	for lang in good_h:
		process_main(lang)


################################################################################
# process_main
#
################################################################################
def process_main(iso_language_hash):

	iso_code           = iso_language_hash['isoCode']
	is_character_based = 'characterBased' in iso_language_hash

	# Get various names
	xml_file = "%swiki-latest-pages-articles-multistream.xml" % iso_code
	bz2_file = "%s.bz2" % xml_file

	# Some of the deafult 'latest' urls are corrupt files
	bz2_url = ''
	if iso_code == 'ru':
		bz2_url = 'https://dumps.wikimedia.org/ruwiki/20150324/ruwiki-20150324-pages-articles-multistream.xml.bz2'
	else:
		bz2_url = "https://dumps.wikimedia.org/%swiki/latest/%s" % (iso_code, bz2_file)

	xml_local_path = os.path.join(wikidumps_path, xml_file)
	bz2_local_path = os.path.join(wikidumps_path, bz2_file)

	# Download the xml.bz2 file
	run_cmd("curl -o %s %s" % (bz2_local_path, bz2_url))

	# Unzip the downloaded file
	run_cmd("bzip2 -ckd %s > %s" % (bz2_local_path, xml_local_path))
	run_cmd("rm %s" % bz2_local_path)

	# Scrape the sections
	scraper_script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/scripts/scraper/scrape_phrase_counts.py')
	run_cmd("python %s %s %s" % (scraper_script_path, iso_code, xml_local_path))

	# Create phrases
	phrases_script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/scripts/scraper/generate_phrases.py')
	run_cmd("python %s %s" % (phrases_script_path, iso_code))

	# Add extra words
	add_sampled_script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/scripts/scraper/add_sampled_phrases.py')
	run_cmd("python %s %s" % (add_sampled_script_path, iso_code))

	# Find translations
	translate_script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/scripts/scraper/generate_translations.py')
	run_cmd("python %s %s" % (translate_script_path, iso_code))

	# Build dictionary
	dictionary_script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/scripts/scraper/generate_dictionary.py')
	run_cmd("python %s %s" % (dictionary_script_path, iso_code))

	# Remove the XML
	run_cmd("rm %s" % xml_local_path)


################################################################################
# run_cmd
#
################################################################################
def run_cmd(cmd):
	print "Running: %s" % cmd
	os.system(cmd)


if __name__ == '__main__':
	main()
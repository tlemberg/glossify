import scraper

h = scraper.get_iso_codes_hash()

things = []
for code, subh in h.iteritems():
	name = subh['name']
	if 'wiktionaryName' in subh:
		name = subh['wiktionaryName']
	print "%s: %s" % (code, name)
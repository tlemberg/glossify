import scraper
import dbutils

h = scraper.get_iso_codes_hash()

db = dbutils.DBConnect()

things = []
for code, subh in h.iteritems():
	name = subh['name']

	c = db.sections.find({'lang': code}).count()

	if c < 10:
		print "%s: %s" % (code, name)
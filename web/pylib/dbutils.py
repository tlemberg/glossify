import pymongo


################################################################################
# get_phrase_for_base
#
################################################################################
def DBConnect(host, user, passwd):
	connect_str = "mongodb://%s:%s@%s/tenk" % (user, passwd, host)
	print connect_str
	client = pymongo.MongoClient(connect_str)
	return client.tenk


################################################################################
# get_section_for_base
#
################################################################################
def get_section_for_phrase(db, phrase):
	base = phrase['base']
	lang = phrase['lang']
	section = db.sections.find_one({ 'base': base, 'lang': lang }, { "text": 1 })
	if section == None:
		section = db.sections.find_one({ 'base': base.title(), 'lang': lang }, { "text": 1 })
		if section == None:
			section = db.sections.find_one({ 'base': base.upper(), 'lang': lang }, { "text": 1 })

	return section


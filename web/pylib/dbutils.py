import pymongo


################################################################################
# get_phrase_for_base
#
################################################################################
def DBConnect():
	client = pymongo.MongoClient('localhost', 27017)
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

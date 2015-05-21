################################################################################
# get_section_for_base
#
################################################################################
def get_section_for_base(base):
	section = mongo.db.sections.find_one({ 'base': base }, { "text": 1 })
	if section == None:
		section = mongo.db.sections.find_one({ 'base': base.title() }, { "text": 1 })
		if section == None:
			section = mongo.db.sections.find_one({ 'base': base.upper() }, { "text": 1 })

	return section


################################################################################
# get_phrase_for_base
#
################################################################################
def get_phrase_for_base(base):
	phrase = mongo.db.phrases.find_one({ 'base': base }, { "text": 1 })
	if phrase == None:
		phrase = mongo.db.phrases.find_one({ 'base': base.title() }, { "text": 1 })
		if phrase == None:
			phrase = mongo.db.phrases.find_one({ 'base': base.upper() }, { "text": 1 })

	return phrase
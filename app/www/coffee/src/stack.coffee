define ['utils', 'storage'], (utils, storage) ->

	SECTION_SIZE    = 1000
	DICTIONARY_SIZE = 10000

	boxSize = 100


	############################################################################
	# _getCards
	#
	############################################################################
	_getCards = (section, box, lang) ->
		lang        = storage.getLanguage()
		userProfile = storage.getUserProfile()

		minIndex = minIndex = (section - 1) * SECTION_SIZE + box * boxSize
		maxIndex = minIndex + boxSize

		userProfile['langs'][lang].slice(minIndex, maxIndex)


	############################################################################
	# _getProgressPercentage
	#
	############################################################################
	_getProgressPercentage = (cards) ->

		# Compute the max progress
		maxProgress = 5 * _deck['cards'].length

		# Compute the total progress
		totalProgress = 0
		for card in _deck['cards']
			totalProgress += card['progress']

		Math.floor(totalProgress / maxProgress * 100)
			

	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		getCards: (section, box, lang) ->
			_getCards(section, box, lang)


		getProgressPercentage: (cards) ->
			_getProgressPercentage(cards)


	}

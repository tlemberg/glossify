define ['utils', 'storage'], (utils, storage) ->

	SECTION_SIZE    = 1000
	DICTIONARY_SIZE = 10000

	boxSize = 100


	############################################################################
	# _getSectionInterval
	#
	############################################################################
	_getSectionInterval = (section) ->
		minIndex = minIndex = (section - 1) * SECTION_SIZE
		maxIndex = minIndex + SECTION_SIZE - 1

		return {
			min: minIndex
			max: maxIndex
		}


	############################################################################
	# _getSectionInterval
	#
	############################################################################
	_getBoxInterval = (section, box) ->
		minIndex = minIndex = (section - 1) * SECTION_SIZE
		maxIndex = minIndex + boxSize

		return {
			min: minIndex
			max: maxIndex
		}


	############################################################################
	# _getCards
	#
	############################################################################
	_getCards = (userProfile, section, boxIndex, lang) ->
		minIndex = minIndex = (section - 1) * SECTION_SIZE + boxIndex * boxSize
		maxIndex = minIndex + boxSize

		userProfile['langs'][lang].slice(minIndex, maxIndex)


	############################################################################
	# _getBoxes
	#
	############################################################################
	_getBoxes = (userProfile, dictionary, section, lang, cardsPerBox) ->
		nBoxes = SECTION_SIZE / cardsPerBox

		boxes = []

		for boxIndex in [0..nBoxes-1]
			cards = _getCards(userProfile, section, boxIndex, lang)

			sampleCards = cards[0..3]
			sampleWords = (dictionary['dictionary'][card['phrase_id']]['base'] for card in sampleCards)
			sample = sampleWords.join(', ') + "..."

			box =
				sample: sample
				index : boxIndex

			boxes.push(box)

		boxes


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

		getSectionInterval: (section) ->
			_getSectionInterval(section)


		getBoxInterval: (section, box) ->
			_getBoxInterval(section, box)


		getCards: (section, box, lang) ->
			_getCards(section, box, lang)


		getBoxes: (userProfile, dictionary, section, lang, cardsPerBox) ->
			_getBoxes(userProfile, dictionary, section, lang, cardsPerBox)


		getProgressPercentage: (cards) ->
			_getProgressPercentage(cards)


	}

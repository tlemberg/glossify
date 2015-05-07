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

			percent = _getProgressPercentage(cards)

			box =
				sample : sample
				index  : boxIndex
				percent: percent

			boxes.push(box)

		boxes


	############################################################################
	# _getProgressPercentage
	#
	############################################################################
	_getProgressPercentage = (cards) ->

		maxProgress = 5 * cards.length

		# Compute the total progress
		totalProgress = 0
		for card in cards
			totalProgress += card['progress']

		console.log("total")
		console.log(totalProgress)

		Math.floor(totalProgress / maxProgress * 100)


	############################################################################
	# _updateCards
	#
	############################################################################
	_updateCards = (cards) ->
		# Get the user profile and language
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()

		console.log(cards)

		# Create mapping
		cardMap = {}
		for card in cards
			cardMap[card['phrase_id']] = card

		# Iterate over progress in user profile
		i = 0
		oldCards = userProfile['langs'][lang]
		for i in [0..oldCards.length-1]
			oldCard = userProfile['langs'][lang][i]
			newCard = cardMap[oldCard['phrase_id']]
			if newCard?
				console.log("UPDATING")
				userProfile['langs'][lang][i]['progress'] = newCard['progress']

		# Save the new object
		storage.setUserProfile(userProfile)
			

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

		updateCards: (cards) ->
			_updateCards(cards)


	}

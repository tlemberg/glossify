define ['utils', 'storage'], (utils, storage) ->


	############################################################################
	# Module properties
	#
	############################################################################
	MAX_BUFFER = 3


	############################################################################
	# _createDeck
	#
	############################################################################
	_createDeck = (phraseIds) ->

		# Get local values
		lang       = storage.getLanguage()
		dictionary = storage.getDictionary(lang)

		# Construct a list of phrases
		phraseList = (dictionary['dictionary'][phraseId] for phraseId in phraseIds)

		# Create a parallel map from ids to phrases
		phraseMap = {}
		for phraseId in phraseIds
			phraseMap[phraseId] = dictionary[phraseId]

		# Make the phrases a property of a deck object
		deck =
			lang       : dictionary['lang']
			phraseList : phraseList
			phraseMap  : phraseMap
			buffer     : []

		# Give the deck object a pool to draw from
		_refreshDeck(deck)

		# Return the modified deck
		deck


	############################################################################
	# _refreshDeck
	#
	############################################################################
	_refreshDeck = (deck) ->

		# Get local values
		lang     = storage.getLanguage()

		# Init list accumulators
		totalPenalty = 0
		maxPenalty   = deck['phraseList'].length
		poolPhrases    = []
		i            = 0

		# Construct a pool to draw from
		while totalPenalty < maxPenalty

			console.log(totalPenalty)
			console.log(maxPenalty)

			# Grab a phrase from the deck
			phrase = deck['phraseList'][i]

			# Increase the total penalty and exit the loop if it is too great
			penalty = 6 - storage.getProgress(phrase['_id']) # Penalty ranges from 0 to 5
			totalPenalty += penalty
			if totalPenalty > maxPenalty then break

			# Add the phrase to the pool
			poolPhrases.push phrase

			i += 1

		console.log("POOL")
		console.log(poolPhrases)

		# Convert the pool phrases into a distribution pool
		p    = 0
		pool = {}
		for phrase in poolPhrases
			penalty = 6 - storage.getProgress(phrase['_id'])
			for a in [0..(penalty-1)]
				do (a) ->
					p += 1
					pool[p] = phrase
	
		# Assign the pool to the deck as a property
		deck['pool']     = pool
		deck['poolSize'] = Object.keys(pool).length


	############################################################################
	# _drawPhrase
	#
	############################################################################
	_drawPhrase = (deck) ->
		console.log(deck)

		while not phrase? or phrase in deck['buffer']
			p = utils.randomInt(0, deck['poolSize'] - 1)
			phrase = deck['pool'][p]

		# Add the phrase to the buffer
		deck['buffer'].push(phrase)
		if deck['buffer'].length > MAX_BUFFER
			deck['buffer'].shift()

		# Return the phrase
		phrase
			

	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		createDeck: (phraseIds) ->
			_createDeck(phraseIds)

		refreshDeck: (deck) ->
			_refreshDeck(deck)
		
		drawPhrase: (deck) ->
			_drawPhrase(deck)

	}

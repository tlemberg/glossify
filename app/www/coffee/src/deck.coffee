define ['utils', 'storage'], (utils, storage) ->

	MAX_BUFFER      = 3
	BOX_SIZE        = 100
	PAGE_SIZE       = 1000
	DICTIONARY_SIZE = 10000

	############################################################################
	# refreshPool
	#
	############################################################################
	refreshPool = (deck) ->
		# Init list accumulators
		totalPenalty = 0
		maxPenalty   = deck.cards.length
		poolCards    = []
		i            = 0

		# Construct a pool to draw from
		while totalPenalty < maxPenalty
			# Grab a card from the deck
			card = deck['cards'][i]

			# Increase the total penalty and exit the loop if it is too great
			penalty = 6 - card['progress'] # Penalty ranges from 0 to 5
			totalPenalty += penalty
			if totalPenalty > maxPenalty then break

			# Add the card to the pool
			poolCards.push card

			i += 1

		# Convert the pool cards into a distribution pool
		p    = 0
		pool = {}
		for card in poolCards
			penalty = 6 - card['progress']
			for a in [0..(penalty-1)]
				do (a) ->
					p += 1
					pool[p] = card
	
		# Assign the pool to the deck as a property
		deck['pool']     = pool
		deck['poolSize'] = Object.keys(pool).length
			

	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		createDeck: (cards, dictionary) ->
			# Create a list of card hashes with progress and progress keys
			cardList = (for card in cards
				phrase_id: card['phrase_id']
				phrase  : dictionary['dictionary'][card['phrase_id']]
				progress: card['progress']
			)

			# Create a parallel map from ids to phrases
			cardMap = {}
			for card in cardList
				cardMap[card['phrase_id']] = card

			# Make the cards a property of a deck object
			deck =
				lang   : dictionary['lang']
				cards  : cardList
				cardMap: cardMap
				buffer : []


			# Give the deck object a pool to draw from
			refreshPool(deck)

			# Return the modified deck
			deck
		
		# Draw a card from the pool, creating a new pool if necessary
		drawCard: (deck) ->

			# Draw from the pool
			while not card? or card in deck['buffer']
				p = utils.randomInt(0, deck['poolSize'] - 1)
				card = deck['pool'][p]

			# Add the card to the buffer
			deck['buffer'].push(card)
			if deck['buffer'].length > MAX_BUFFER
				deck['buffer'].shift()

			# Return the card
			card

		# Reassign progress and potentially refresh the pool, if required
		updateCard: (deck, card) ->
			deck['cards'][card['phrase_id']] = card
			refreshPool(deck)

		boxSize: ->
			BOX_SIZE

		pageSize: ->
			PAGE_SIZE

		dictionarySize: ->
			DICTIONARY_SIZE

	}

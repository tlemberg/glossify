define ['utils'], (utils) ->

	MAX_BUFFER = 3

	# Pulls a card from a deck object
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

		########################################################################
		# Creates and returns a deck object, which has the following properties
		#
		#	cards  : a list of cards in the deck
		#	cardMap: a hash mapping phraseIds to phrase objects
		#	pool   : a distribution from which cards can be drawn (is a hash)
		#	buffer : a small list of cards that have been recently drawn
		#
		########################################################################
		createDeck: (cards, dictionary) ->
			# Create a list of card hashes with progress and progress keys
			cardList = (for card in cards
				phraseId: card['phrase_id']
				phrase  : dictionary['dictionary'][card['phrase_id']]
				progress: card['progress']
			)

			# Create a parallel map from ids to phrases
			cardMap = {}
			for card in cardList
				cardMap[card['phraseId']] = card

			# Make the cards a property of a deck object
			deck =
				cards  : cardList
				cardMap: cardMap
				buffer : []


			# Give the deck object a pool to draw from
			refreshPool(deck)

			# Return the modified deck
			deck

		
		# Draw a card from the pool, creating a new pool if necessary
		drawCard: (deck) ->

			console.log(deck['pool'])

			# Draw from the pool
			while not card? or card in deck['buffer']
				p = utils.randomInt(0, deck['poolSize'] - 1)
				console.log(p)
				card = deck['pool'][p]

			# Add the card to the buffer
			deck['buffer'].push(card)
			if deck['buffer'].length > MAX_BUFFER
				deck['buffer'].shift()

			# Return the card
			card



		# Reassign progress and potentially refresh the pool, if required
		updateCard: (deck, card) ->
			deck['cards'][card['phraseId']] = card
			refreshPool(deck)




	}

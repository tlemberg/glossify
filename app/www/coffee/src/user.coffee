define ['api'], (api) ->


	############################################################################
	# _updateUserProfile
	#
	#	Accepts a set of cards and updates the userProfile based on those
	#	cards. The resulting userProfile is stored in localStorage and added
	#	to a queue for syncing via the API.
	#
	# Parameters:
	#
	#	Required:
	#		userProfile		a userProfile object for the active user
	#		lang			the language for the update
	#		tileId			the index of the tile where the cards live
	#		cards			the card objects
	#		handler			method to call on success/failure
	#	
	# Returns:
	#	Nothing
	############################################################################
	_updateUserProfile = (userProfile, lang, tileId, cards, handler) ->

		# Create a mapping of phrase_id keys to progress values
		progressMap = {}
		for card in cards
			progressMap[card['phrase_id']] = card['progress']

		# Iterate over the cards, updating the progress for each card
		existingCards = userProfile['langs'][lang][_tileId]
		syncRequired = false
		for card in existingCards
			syncRequired ||= card['progress'] != progressMap[card['phrase_id']]
			card['progress'] = progressMap[card['phrase_id']]

		if syncRequired
			api.syncUserProfile(userProfile, handler)
		else
			handler()


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		updateUserProfile: (userProfile, lang, tileId, cards, handler) ->
			_updateUserProfile(email, cards, handler)

	}


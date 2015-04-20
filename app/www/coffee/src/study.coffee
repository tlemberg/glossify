define ['utils', 'nav', 'deck', 'css'], (utils, nav, deck, css) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav       = undefined
	_isFlipped = false
	_card      = undefined
	_deck      = undefined


	############################################################################
	# UI constants
	#
	############################################################################
	BG_COLORS = ['#333333', '#ff0000', '#ff9900', '#009933', '#6600cc', '#0066ff']


	############################################################################
	# preloadStudyPage
	#
	#	Generates the elements of the page that only need to be built once
	#
	# Parameters:
	#
	#	userProfile: userProfile hash
	#	dictionary : dictionary hash
	#	params     : extra parameters
	#	
	# Returns:
	#	Nothing
	############################################################################
	_preloadPage = ->
		# Load the footer
		_setStudyFooterHtml()

		$('.study-btn').click (event) ->
			# Update progress on the card
			_card['progress'] = $(this).data('progress')
			deck.updateCard(_deck, _card)

			console.log('drawing card')

			# Draw a new card
			_card = deck.drawCard(_deck)
			console.log(_card)

			# Refresh the page
			_refreshPage()

		$('#study-flip-button').click (event) ->
			_isFlipped = true
			_refreshPage()

		$('#study-back-btn').click (event) ->
			api.updateUserPofile _userProfile, (json) ->
				if not json['success']
					console.log(json)
				_nav.loadPage('overview')


	############################################################################
	# preloadStudyPage
	#
	#	Generates the elements of the page that only need to be built once
	#
	# Parameters:
	#
	#	userProfile: userProfile hash
	#	dictionary : dictionary hash
	#	params     : extra parameters
	#	
	# Returns:
	#	Nothing
	############################################################################
	_refreshPage = ->
		_setStudyFooterCss()

		_setHeaderCss()

		# Change the height of the content pane
		_refreshContentPane()

		# Set progress counter
		_setProgressCounter()

		$('.study-footer').css('height', getFooterHeight())

		$('.study-content').css('border-color', BG_COLORS[_card['progress']])

		# Set the text to match the card
		_setTopText(_card['phrase']['base'])

		if not _isFlipped
			# Build the flip buton UI and show it
			_showFlipButton()
		else
			# Get a translation summary and set it in the UI
			txSummary = _getTxSummary(_card['phrase']['txs'])
			_setBottomText(txSummary)

			# Show the appropriate divs
			_hideFlipButton()


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (params) ->
		# Extract some parameters
		_userProfile = params['userProfile']
		dictionary = storage.getDictionary('')
		_tileId      = params['tileId']


		lang = _dictionary['lang']

		# Get the cards from the user profile
		cards = _userProfile['langs'][lang][_tileId]

		# Construct a deck and store is as a module variable
		_deck = deck.createDeck(cards, _dictionary)

		# Draw a card to start the deck
		_card = deck.drawCard(_deck)

		# Set other properties
		_isFlipped = false


	############################################################################
	# _setProgressCounter
	#
	############################################################################
	_setProgressCounter = () ->
		# Compute the max progress
		maxProgress = 5 * _deck['cards'].length

		# Compute the total progress
		totalProgress = 0
		for card in _deck['cards']
			totalProgress += card['progress']

		percentProgress = Math.floor(totalProgress / maxProgress * 100)

		$('#study-progress-counter').html("#{ percentProgress }%")

		bin = Math.floor(percentProgress / 25) + 1
		$('#study-progress-counter').css('background-color', BG_COLORS[bin])


	############################################################################
	# _setTopText
	#
	############################################################################
	_setTopText = (text) ->
		$('#study-top-text').html(text)


	############################################################################
	# _setBottomText
	#
	############################################################################
	_setBottomText = (text) ->
		$('#study-bottom-text').html(text)


	############################################################################
	# _showFlipButton
	#
	############################################################################
	_showFlipButton = ->
		$('#study-flip-btn-container').show()
		$('#study-bottom-text').hide()
		$('#study-btn-container').hide()


	############################################################################
	# _hideFlipButton
	#
	############################################################################
	_hideFlipButton = ->
		$('#study-flip-btn-container').hide()
		$('#study-bottom-text').show()
		$('#study-btn-container').show()


	############################################################################
	# _getTxSummary
	#
	############################################################################
	_getTxSummary = (txs) ->
		s = ''
		for k, v of txs
			defTexts = (def['text'] for def in v when not def['deleted'])
			lines = ("#{ i + 1 }. #{ defTexts[i] }" for i in [0..(defTexts.length - 1)])
			s = s + "<b>#{ k }</b>" + "<br />" + lines.join("<br />")


	############################################################################
	# _setStudyFooterHtml
	#
	############################################################################
	_setStudyFooterHtml = ->
		# Set the footer's html
		footerHtml = (for c in [1..5]
			"""
			<div id='study-btn-#{ c }' class='study-btn' data-progress=#{ c }>
				<div class='study-btn-text'>#{ c }</div>
			</div>
			""").join("\n")
		$('#study-btn-container').html(footerHtml)

		# Assign colors
		for c in [1..5]
			do (c) ->
				$("#study-btn-#{ c }").css('background-color', BG_COLORS[c])


	############################################################################
	# _setHeaderCss
	#
	############################################################################
	_setHeaderCss = ->
		$('#study-header').css('height', utils.withUnit(css.getStaticCss('study', 'header', 'height')))


	############################################################################
	# _getFooterHeight
	#
	############################################################################
	_getFooterHeight = ->
		utils.appWidth() / 5


	############################################################################
	# _setStudyFooterCss
	#
	############################################################################
	_setStudyFooterCss = ->
		btnWidth = getFooterHeight()

		# Set the tile width and heights
		$('.study-btn').css('width', btnWidth)
		$('.study-btn').css('height', btnWidth)


	############################################################################
	# _refreshContentPane
	#
	############################################################################
	_refreshContentPane = ->
		# Collect the heights of existing elements
		headerHeight = utils.stripNumeric(css.getStaticCss('study', 'header', 'height'))

		# Calculate the new height of the content pane and set it
		contentMargin = utils.stripNumeric(css.getStaticCss('study', 'container', 'padding'))
		borderWidth = utils.stripNumeric(css.getStaticCss('study', 'content', 'border-width'))
		contentHeight = utils.appHeight() - getFooterHeight() - contentMargin * 2 - headerHeight
		$('#study-container').css('height', contentHeight)


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		preloadPage: ->
			_nav = require('nav')
			_preloadPage()


		refreshPage: ->
			_refreshPage()


		loadPage: (params) ->
			_loadPage(params)


	}


define ['utils', 'stack', 'storage', 'nav', 'deck', 'css', 'pageview'], (utils, stack, storage, nav, deck, css, pageview) ->


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
	MAX_CARD_WIDTH = 340
	MAX_BUTTON_AREA_WIDTH = 600
	CARD_ASPECT = 1.5


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()
		section     = storage.getSection()
		box         = storage.getBox()
		dictionary  = storage.getDictionary(lang)

		minIndex = minIndex = (section - 1) * deck.boxSize() + box * deck.boxSize()
		maxIndex = minIndex + deck.boxSize()

		interval = stack.getBoxInterval(section, box)

		cards = userProfile['langs'][lang].slice(interval['min'], interval['max'])

		console.log(cards)

		# Construct a deck and store is as a module variable
		_deck = deck.createDeck(cards, dictionary)

		# Draw a card to start the deck
		_card = deck.drawCard(_deck)

		# Set other properties
		_isFlipped = false

		templateArgs =
			buttons: [
				{ progress: 1, text: "don't know"},
				{ progress: 2, text: ""},
				{ progress: 3, text: ""},
				{ progress: 4, text: ""},
				{ progress: 5, text: "know"},
			]

		$(".study-page").html(template(templateArgs))

		_setStudyFooterCss()

		_resetCard()

		_nav.showBackBtn "Done", (event) ->
			_nav.loadPage('overview')

		_registerEvents()


	############################################################################
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->
		$('.study-page .flip-btn').click (event) ->
			_isFlipped = true
			_resetCard()

		$('.study-page .btn').click (event) ->
			# Update progress on the card
			_card['progress'] = $(this).data('progress')
			deck.updateCard(_deck, _card)
			stack.updateCards([_card])

			# Draw a new card
			_card = deck.drawCard(_deck)

			# Refresh the page
			_isFlipped = false
			_resetCard()

		$('.study-page .back-btn').click (event) ->

			section = storage.getSection()
			box     = storage.getBox()
			lang    = storage.getLanguage()
			cards   = stack.getCards(section, box, lang)

			_nav.loadPage('overview')


	############################################################################
	# _resetCard
	#
	############################################################################
	_resetCard = ->
		# Set the text to match the card
		_setTopText(_card['phrase']['base'])

		# Set the border color to indicate progress
		progress = _card['progress']
		for i in [0..5]
			$('.study-page .card').removeClass("card-progress-#{ i }")
		$('.study-page .card').addClass("card-progress-#{ progress }")

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
	# _setTopText
	#
	############################################################################
	_setTopText = (text) ->
		$('.study-page .card-top-text').html(text)


	############################################################################
	# _setBottomText
	#
	############################################################################
	_setBottomText = (text) ->
		$('.study-page .card-bottom-text').html(text)


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->

		_setStudyFooterCss()

		_setHeaderCss()

		# Change the height of the content pane
		_refreshContentPane()

		# Set progress counter
		_setProgressCounter()

		$('.study-footer').css('height', page.getFooterHeight())



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
	# _showFlipButton
	#
	############################################################################
	_showFlipButton = ->
		$('.study-page .flip-btn').show()
		$('.study-page .card-bottom-text').hide()
		$('.study-page .btn-container').hide()


	############################################################################
	# _hideFlipButton
	#
	############################################################################
	_hideFlipButton = ->
		$('.study-page .flip-btn').hide()
		$('.study-page .card-bottom-text').show()
		$('.study-page .btn-container').show()


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
	# _setStudyFooterCss
	#
	############################################################################
	_setStudyFooterCss = ->
		cardWidth = Math.min(MAX_CARD_WIDTH, utils.windowWidth())
		cardHeight = cardWidth * CARD_ASPECT

		$('.study-page .card-container').css('width', cardWidth);

		#$('.study-page .card').css('width', cardWidth)
		$('.study-page .card').css('height', cardHeight)

		btnWidth = (cardWidth - 20) / 5

		# Set the tile width and heights
		$('.study-page .btn').css('width', btnWidth)
		$('.study-page .btn').css('height', btnWidth)
		$('.study-page .btn').css('margin-top', '5px')
		$('.study-page .btn').css('margin-right', '5px')
		$('.study-page .btn-5').css('margin-right', '0px')

		$('.study-page .flip-btn').css('height', btnWidth)


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
		contentHeight = utils.appHeight() - page.getFooterHeight() - contentMargin * 2 - headerHeight
		$('#study-container').css('height', contentHeight)


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		loadPage: (template) ->
			_nav = require('nav')
			_loadPage(template)

		refreshPage: ->
			_refreshPage()


	}


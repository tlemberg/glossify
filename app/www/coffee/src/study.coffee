define [
	'utils',
	'stack',
	'storage',
	'nav',
	'deck',
	'pageview',
	'api',
	'hbs!../../hbs/src/wordref',
], (utils, stack, storage, nav, deck, pageview, api, wordrefTemplate) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav       = undefined
	_isFlipped = false
	_phrase    = undefined
	_deck      = undefined


	############################################################################
	# UI constants
	#
	############################################################################
	MAX_BUTTON_AREA_WIDTH = 600
	CARD_ASPECT = .68


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->

		# Get local values
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()
		section     = storage.getSection()
		box         = storage.getBox()
		plan        = storage.getPlan(lang)
		dictionary  = storage.getDictionary(lang)

		# Get phrase IDs for the current box
		phraseIds = stack.getPhraseIds(plan, section, box, lang)

		# Construct a deck and store is as a module variable
		_deck = deck.createDeck(phraseIds, dictionary)

		# Draw a phrase to start the deck
		_phrase = deck.drawPhrase(_deck)

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
			progressUpdates = storage.getProgressUpdates()
			if progressUpdates? and progressUpdates != {}
				api.updateProgress (json) ->
					_nav.loadPage('overview')
			else
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

			# Update the progress value
			storage.setProgress(_phrase['_id'], $(this).data('progress'))

			# Refresh the deck
			deck.refreshDeck(_deck)

			# Draw a new card
			_phrase = deck.drawPhrase(_deck)

			# Refresh the page
			_isFlipped = false
			_resetCard()


	############################################################################
	# _resetCard
	#
	############################################################################
	_resetCard = ->

		# Set the text to match the card
		topText = ''
		if _phrase['pron']?
			topText = "#{_phrase['base']} (#{_phrase['pron']})"
		else
			topText = _phrase['base']
		_setTopText(topText)

		# Set the border color to indicate progress
		progressValue = storage.getProgress(_phrase['_id'])
		for i in [0..5]
			$('.study-page .card').removeClass("card-progress-#{ i }")
		$('.study-page .card').addClass("card-progress-#{ progressValue }")

		if not _isFlipped
			# Build the flip buton UI and show it
			_showFlipButton()
		else
			# Get a translation summary and set it in the UI
			txSummary = _getTxSummary(_phrase['txs'])
			_setBottomText(txSummary)

			# Show the appropriate divs
			_hideFlipButton()

		lang = storage.getLanguage()
		templateArgs =
			lang: lang
			base: _phrase['base']
			"lang_#{lang}": 1
		$(".wordref-menu").html(wordrefTemplate(templateArgs))


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
		types = Object.keys(txs).sort (a, b) ->
			txs[b].length - txs[a].length
		chunks = []
		for k in types[0..1]
			v = txs[k]
			lines = ("#{ i + 1 }. #{ v[i] }" for i in [0..Math.min(v.length - 1, 1)])
			chunks.push("<div><b>#{ k }</b>" + "<br />" + lines.join("<br />") + "</div>")
		chunks.join("<br />")


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
	# _setStudyFooterCss
	#
	############################################################################
	_setStudyFooterCss = ->

		cardHeight = utils.windowHeight() - 200
		cardWidth  = Math.min(cardHeight / CARD_ASPECT, utils.windowWidth() - 60)

		$('.study-page .card-container').css('width', cardWidth);

		#$('.study-page .card').css('width', cardWidth)
		$('.study-page .card').css('height', cardHeight)

		btnWidth = (cardWidth - 60) / 5

		# Set the tile width and heights
		$('.study-page .btn').css('width', btnWidth)
		$('.study-page .btn').css('height', '50px')
		$('.study-page .btn').css('margin-top', '15px')
		$('.study-page .btn').css('margin-right', '15px')
		$('.study-page .btn-5').css('margin-right', '0px')

		$('.study-page .flip-btn').css('height', '50px')


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


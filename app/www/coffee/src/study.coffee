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
	_template  = undefined
	_phraseIds = undefined


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

		_template = template

		# Get local values
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()
		section     = storage.getSection()
		box         = storage.getBox()
		plan        = storage.getPlan(lang)
		dictionary  = storage.getDictionary(lang)

		studyMode = storage.getStudyMode() ? 'defs'
		studyOrder = storage.getStudyOrder() ? 'toEnglish'
		storage.setStudyMode(studyMode)
		storage.setStudyOrder(studyOrder)

		# Get phrase IDs for the current box
		_phraseIds = stack.getPhraseIds(plan, section, box, lang)

		# Construct a deck and store is as a module variable
		_deck = deck.createDeck(_phraseIds, dictionary)

		# Draw a phrase to start the deck
		_phrase = deck.drawPhrase(_deck)

		# Set other properties
		_isFlipped = false

		# Is this a character-based language?
		includePron = undefined
		if lang == 'he' or lang == 'zh'
			includePron = 1

		constants = require('constants')

		templateArgs =
			buttons: [
				{ progress: 1, text: "don't know"},
				{ progress: 2, text: ""},
				{ progress: 3, text: ""},
				{ progress: 4, text: ""},
				{ progress: 5, text: "know"},
			]
			lang_name: constants.langMap[lang]
			include_pron: includePron

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

		_resetProgress()


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
			storage.setProgress(_phrase['_id'], $(this).data('progress'), storage.getStudyMode())

			# Refresh the deck
			deck.refreshDeck(_deck)

			# Draw a new card
			_phrase = deck.drawPhrase(_deck)

			# Refresh the page
			_isFlipped = false
			_resetCard()
			_resetProgress()

		$('.study-page .study-mode-select').change (event) ->
			studyDescription = $(this).val()
			if studyDescription == 'phrase-def'
				studyMode = 'defs'
				studyOrder = 'toEnglish'
			else if studyDescription == 'def-phrase'
				studyMode = 'defs'
				studyOrder = 'fromEnglish'
			else if studyDescription == 'phrase-pron'
				studyMode = 'pron'
				studyOrder = 'toEnglish'
			else if studyDescription == 'pron-phrase'
				studyMode = 'pron'
				studyOrder = 'fromEnglish'
			storage.setStudyMode(studyMode)
			storage.setStudyOrder(studyOrder)
			_nav.loadPage('study')


	############################################################################
	# _resetProgress
	#
	############################################################################
	_resetProgress = ->
		for studyMode in ['defs', 'pron']
			progressHash = {
				1: 0
				2: 0
				3: 0
				4: 0
				5: 0
			}
			for phraseId in _phraseIds
				progress = storage.getProgress(phraseId, studyMode)
				if progress > 0
					progressHash[progress] += 1
			for progress in Object.keys(progressHash)
				count = progressHash[progress]
				percent = (count / _phraseIds.length * 98) + 2
				widthStr = utils.withUnit(percent, '%')
				$(".study-page .progress-box-#{ studyMode } .progress-bar-#{ progress }").css('width', widthStr)


	############################################################################
	# _resetCard
	#
	############################################################################
	_resetCard = ->

		studyMode = storage.getStudyMode()
		studyOrder = storage.getStudyOrder()

		studyDescription = undefined
		if studyMode == 'defs'
			if studyOrder == 'toEnglish'
				studyDescription = 'phrase-def'
			else
				studyDescription = 'def-phrase'
		else
			if studyOrder == 'toEnglish'
				studyDescription = 'phrase-pron'
			else
				studyDescription = 'pron-phrase'


		# Set the text to match the card
		phraseText = ''
		if studyDescription == 'phrase-def'
			#if _phrase['pron']?
			#	phraseText = "#{_phrase['base']} (#{_phrase['pron']})"
			#else
			phraseText = _phrase['base']
		else
			phraseText = _phrase['base']

		# Get a translation summary and set it in the UI
		defText = ''
		if studyDescription == 'phrase-def' or studyDescription == 'def-phrase'
			defText = _getTxSummary(_phrase['txs'])			

		# Get the pronunciation text
		pronText = ''
		if studyDescription == 'phrase-pron' or studyDescription == 'pron-phrase'
			pronText = _phrase['pron']

		if studyDescription == 'phrase-def' or studyDescription == 'phrase-pron'
			$('.study-page .card-top-text').addClass('big-font-half')
			$('.study-page .card-top-text').removeClass('small-font-half')
			$('.study-page .card-bottom-text').addClass('small-font-half')
			$('.study-page .card-bottom-text').removeClass('big-font-half')
		else
			$('.study-page .card-top-text').addClass('small-font-half')
			$('.study-page .card-top-text').removeClass('big-font-half')
			$('.study-page .card-bottom-text').addClass('big-font-half')
			$('.study-page .card-bottom-text').removeClass('small-font-half')

		# Set the top text
		if studyDescription == 'phrase-def'
			_setTopText(phraseText)
		else if studyDescription == 'def-phrase'
			_setTopText(defText)
		else if studyDescription == 'phrase-pron'
			_setTopText(phraseText)
		else if studyDescription == 'pron-phrase'
			_setTopText(pronText)

		# Set the border color to indicate progress
		progressValue = storage.getProgress(_phrase['_id'], studyMode)
		for i in [0..5]
			$('.study-page .card').removeClass("card-progress-#{ i }")
		$('.study-page .card').addClass("card-progress-#{ progressValue }")

		if not _isFlipped
			# Build the flip buton UI and show it
			_showFlipButton()
		else
			if studyDescription == 'phrase-def'
				_setBottomText(defText)
			else if studyDescription == 'def-phrase'
				_setBottomText(phraseText)
			else if studyDescription == 'phrase-pron'
				_setBottomText(pronText)
			else if studyDescription == 'pron-phrase'
				_setBottomText(phraseText)

			# Show the appropriate divs
			_hideFlipButton()

		lang = storage.getLanguage()

		templateArgs =
			lang: lang
			base: _phrase['base']
			"lang_#{lang}": 1
		$(".wordref-menu").html(wordrefTemplate(templateArgs))
		$(".study-page .study-mode-select").val(studyDescription)


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
		#cardWidth  = Math.min(cardHeight / CARD_ASPECT, utils.windowWidth() - 60)
		cardWidth = utils.stripNumeric($('.study-page .card').css('width'))

		#$('.study-page .card-container').css('width', cardWidth);

		#$('.study-page .card').css('width', cardWidth)
		$('.study-page .card').css('height', cardHeight)

		btnWidth = (cardWidth - 60 - 6) / 5

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


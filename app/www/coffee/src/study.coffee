define [
	'utils',
	'stack',
	'storage',
	'nav',
	'deck',
	'pageview',
	'api',
	'constants',
	'hbs!../../hbs/src/wordref',
	'hbs!../../hbs/src/summary',
	'hbs!../../hbs/src/phrase-popup',
], (utils, stack, storage, nav, deck, pageview, api, constants, wordrefTemplate, summaryTemplate, phrasePopupTemplate) ->


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
	_excerpt   = undefined
	strokesUrlBase = 'https://s3-us-west-2.amazonaws.com/glossify.net/strokes'
	strokesUrlExt  = '.gif'


	############################################################################
	# UI constants
	#
	############################################################################
	MAX_BUTTON_AREA_WIDTH = 600
	CARD_ASPECT = .68


	############################################################################
	# _getStrokesUrl
	#
	############################################################################
	_getStrokesUrls = ->
		gbk_strs = _phrase['strokes']
		if gbk_strs?
			("#{ strokesUrlBase }/#{ gbk_str }#{ strokesUrlExt }" for gbk_str in gbk_strs)


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
		planMode    = storage.getPlanMode()
		dictionary  = storage.getDictionary(lang)

		studyMode = storage.getStudyMode() ? 'defs'
		studyOrder = storage.getStudyOrder() ? 'toEnglish'
		storage.setStudyMode(studyMode)
		storage.setStudyOrder(studyOrder)

		# Set info about the deck in module vars
		_setDeckProperties()

		# Construct a deck and store is as a module variable
		_deck = deck.createDeck(_phraseIds, dictionary)

		# Draw a phrase to start the deck
		_phrase = deck.drawPhrase(_deck, studyMode)

		# Set other properties
		_isFlipped = false

		# Is this a character-based language?
		includePron = undefined
		if lang == 'he' or lang == 'zh'
			includePron = 1

		constants = require('constants')

		summaryPhrases = []
		for phraseId in _phraseIds
			phrase = dictionary['dictionary'][phraseId]
			defText = _getTxSummary(phrase['txs'])
			summaryPhrases.push
				base: phrase['base']
				pron: phrase['pron']
				tx_summary: defText
				phrase_id: phrase['_id']

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
			excerpt: _excerpt

		$(".study-page").html(template(templateArgs))

		_setStudyFooterCss()

		_resetCard()

		_nav.showBackBtn "Done", (event) ->
			_nav.loadPage('overview')

		# Refresh the summary
		_resetSummary()

		_registerEvents()

		_resetProgress()
		_updateConsole()



	############################################################################
	# _setDeckProperties
	#
	############################################################################
	_setDeckProperties = ->

		# Get phrase IDs for the current box
		excerptId = storage.getExcerptId()
		excerpts  = storage.getExcerpts()
		
		excerpt = excerpts[excerptId]
		_excerpt = excerpt['excerpt']
		_phraseIds = excerpt['phrase_ids']
		


	############################################################################
	# _updateConsole
	#
	############################################################################
	_updateConsole = ->
		showPron = storage.getShowPron()
		if showPron
			$('.study-page .show-pron-btn').html('Hide pronunciation')
		else
			$('.study-page .show-pron-btn').html('Show pronunciation')
		studyMode = storage.getStudyMode()
		if studyMode == 'defs'
			$('.study-page .show-pron-btn').show()
			$('.study-page .change-study-mode-btn').html('Study pronunciation')
		else
			$('.study-page .show-pron-btn').hide()
			$('.study-page .change-study-mode-btn').html('Study definitions')


	############################################################################
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->
		$('.page').scroll (event) ->
			$('.study-page .phrase-popup').css('top', '-100px')

		$('.study-page .show-pron-btn').click (event) ->
			showPron = storage.getShowPron()
			if showPron
				showPron = false
			else
				showPron = true
			storage.setShowPron(showPron)
			_updateConsole()
			_resetCard()

		$('.study-page .flip-btn').click (event) ->
			_isFlipped = true
			_resetCard()

		$('.study-page .btn').click (event) ->

			# Update the progress value
			storage.setProgress(_phrase['_id'], $(this).data('progress'), storage.getStudyMode())

			# Refresh the deck
			studyMode = storage.getStudyMode()
			deck.refreshDeck(_deck, studyMode)

			# Draw a new card
			_phrase = deck.drawPhrase(_deck)

			# Refresh the page
			_isFlipped = false
			_resetCard()
			_resetProgress()

		$('.change-order-btn').click (event) ->
			studyOrder = storage.getStudyOrder()
			if studyOrder == 'toEnglish'
				studyOrder = 'fromEnglish'
			else
				studyOrder = 'toEnglish'
			storage.setStudyOrder(studyOrder)
			_resetCard()
			_updateConsole()

		$('.change-study-mode-btn').click (event) ->
			studyMode = storage.getStudyMode()
			if studyMode == 'defs'
				studyMode = 'pron'
			else
				studyMode = 'defs'
			storage.setStudyMode(studyMode)
			_resetCard()
			_updateConsole()

		$('.forget-progress-btn').click (event) ->
			for studyMode in ['defs', 'pron']
				for phraseId in _phraseIds
					currentProgress = storage.getProgress(phraseId, studyMode)
					storage.setProgress(phraseId, Math.max(0, currentProgress - 1), studyMode)
			lang = storage.getLanguage()
			dictionary = storage.getDictionary(lang)
			_deck = deck.createDeck(_phraseIds, dictionary)
			_resetProgress()



		$('.study-page .card-reveal-btn').click (event) ->
			$('.study-page .card-reveal-txt').show()
			$('.study-page .card-reveal-btn').hide()

		$('.study-page .excerpt').mouseup (event) ->
			text = window.getSelection().toString()
			lang = storage.getLanguage()
			dictionary = storage.getDictionary(lang)
			phrase = dictionary['lookup'][text]
			_showPhrasePopup(phrase, event.pageX, event.pageY)


	############################################################################
	# _showPhrasePopup
	#
	############################################################################
	_showPhrasePopup = (phrase, x, y) ->

		templateArgs =
			unknown: 1
		if phrase?
			defText = _getTxSummary(phrase['txs'])
			templateArgs = 
				base: phrase['base']
				pron: phrase['pron']
				tx_summary: defText
		
		$(".study-page .phrase-popup").html(phrasePopupTemplate(templateArgs))
		$(".study-page .phrase-popup").css('position', 'fixed')
		$(".study-page .phrase-popup").css('left', "#{x}px")
		$(".study-page .phrase-popup").css('top', "#{y+80}px")


	############################################################################
	# _resetProgress
	#
	############################################################################
	_resetProgress = ->
		stack.updateProgressBars('study-page', _phraseIds)


	############################################################################
	# _resetSummary
	#
	############################################################################
	_resetSummary = ->

		lang = storage.getLanguage()
		dictionary = storage.getDictionary(lang)

		summaryPhrases = []
		for phraseId in _phraseIds
			phrase = dictionary['dictionary'][phraseId]
			defText = _getTxSummary(phrase['txs'])
			rankDescription = 'rare'
			if phrase['rank'] < 100
				rankDescription = 'very important'
			else if phrase['rank'] < 1000
				rankDescription = 'important'
			else if phrase['rank'] < 5000
				rankDescription = 'common'
			summaryPhrases.push
				base: phrase['base']
				pron: phrase['pron']
				tx_summary: defText
				phrase_id: phrase['_id']
				rank_description: rankDescription

		templateArgs =
			summary_phrases: summaryPhrases
		$(".deck-summary").html(summaryTemplate(templateArgs))

		$('.study-page .delete-card-btn').click (event) ->
			phraseId = $(this).data('phrase-id')
			storage.deleteCard(storage.getBox(), phraseId)

			# Set info about the deck in module vars
			_setDeckProperties()

			# Refresh the deck
			studyMode = storage.getStudyMode()
			deck.refreshDeck(_deck, studyMode)

			# Draw a new card
			_phrase = deck.drawPhrase(_deck)

			# Refresh the page
			_isFlipped = false
			_resetCard()
			_resetProgress()

			# Refresh the summary
			_resetSummary()


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
			if storage.getShowPron() and _phrase['pron']?
				phraseText = "#{_phrase['base']} (#{_phrase['pron']})"
			else
				phraseText = _phrase['base']
		else
			phraseText = _phrase['base']

		# Get the context within an excerpt
		excerptHtml = undefined
		if _excerpt and studyMode == 'defs'?
			index = 0
			phraseLength = _phrase['base'].length
			for i in [0.._excerpt.length-phraseLength+1]
				j = i + phraseLength
				sub = _excerpt.substring(i, j)
				if sub == _phrase['base']
					index = i
					break
			leftIndex = Math.max(0, index - 8)
			rightIndex = Math.min(_excerpt.length, index + phraseLength + 8)
			left = _excerpt.substring(leftIndex, index)
			right = _excerpt.substring(index + phraseLength, rightIndex)
			leftElipses = ''
			rightElipses = ''
			if left != 0
				leftElipses = '...'
			if rightIndex != _excerpt.length
				rightElipses = '...'
			excerptHtml = "#{ leftElipses }#{ left }<span style='color:red'>#{ _phrase['base'] }</span>#{ right }#{ rightElipses }"

		# Get a translation summary and set it in the UI
		defText = _getTxSummary(_phrase['txs'])		

		$('.study-page .card-reveal-txt').html(defText)
		if _isFlipped and studyMode == 'pron'
			$('.study-page .card-reveal-btn').show()
			$('.study-page .card-reveal-txt').hide()
		else
			$('.study-page .card-reveal-btn').hide()
			$('.study-page .card-reveal-txt').hide()

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

		_setTopExcerpt(excerptHtml)

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
				strokeUrls = _getStrokesUrls(_phrase)
				if strokeUrls?
					_setBottomStrokes(strokeUrls)
				else
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
	# _setTopExcerpt
	#
	############################################################################
	_setTopExcerpt = (excerptHtml) ->
		$('.study-page .card-top-excerpt').html(excerptHtml)


	############################################################################
	# _setBottomText
	#
	############################################################################
	_setBottomText = (text) ->
		$('.study-page .card-bottom-text').html(text)


	############################################################################
	# _setBottomStrokes
	#
	############################################################################
	_setBottomStrokes = (strokeUrls) ->
		$(".study-page .stroke-holder").attr('src', '#')
		$(".study-page .stroke-holder").css('width', '0px')
		$(".study-page .stroke-holder").css('visibility', 'hidden')
		for i in [1..strokeUrls.length]
			strokeUrl = strokeUrls[i-1]
			$(".study-page .stroke-holder-#{ i }").attr('src', strokeUrl)
			$(".study-page .stroke-holder-#{ i }").css('width', '60px')
			$(".study-page .stroke-holder-#{ i }").css('visibility', 'visible')
		$('.study-page .card-bottom-text').html('')
		$(".study-page .stroke-holder").show()


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
		$('.study-page .btn-container').hide()

		$('.study-page .card-bottom-text').addClass('not-flipped')

		$(".study-page .stroke-holder").hide()

		studyMode = storage.getStudyMode()
		studyOrder = storage.getStudyOrder()
		if studyMode == 'defs'
			if studyOrder == 'toEnglish'
				_setBottomText('in English?')
			else
				langName = constants.langMap[storage.getLanguage()]
				_setBottomText("in #{langName}?")
		else
			if studyOrder == 'toEnglish'
				_setBottomText('pronunciation?')
			else
				langName = constants.langMap[storage.getLanguage()]
				_setBottomText("in #{langName}?")

		$('.study-page .card-reveal-btn').hide()
		$('.study-page .card-reveal-txt').hide()
		


	############################################################################
	# _hideFlipButton
	#
	############################################################################
	_hideFlipButton = ->
		$('.study-page .flip-btn').hide()
		$('.study-page .btn-container').show()
		$('.study-page .card-bottom-text').removeClass('not-flipped')

		studyMode = storage.getStudyMode()
		studyOrder = storage.getStudyOrder()

		if studyMode == 'pron'
			$('.study-page .card-reveal-btn').show()


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
			lines = ("#{ i + 1 }. #{ v[i] }" for i in [0..Math.min(v.length - 1, 4)])
			if k == 'unknown'
				chunks.push(lines.join("<br />"))
			else
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


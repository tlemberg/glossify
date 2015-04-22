define ['utils', 'storage', 'nav', 'css', 'deck'], (utils, storage, nav, css, deck) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined

	
	############################################################################
	# UI constants
	#
	############################################################################
	PICKER_TILE_MARGIN = 10


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_preloadPage = ->
		console.log('preload')


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_refreshPage = ->
		console.log('refresh')


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_loadPage = (params) ->

		# Ensure progress is here
		lang = storage.getLanguage()
		userProfile = storage.getUserProfile()
		if lang not in Object.keys(userProfile['langs'])
			_createEmptyProgress()

		# Build header
		$('#overview-header').html('FRENCH')

		# Build footer
		section = storage.getSection()
		if not section
			section = 1

		_setSection(section)

		# Register page events
		_registerEvents()
		

	############################################################################
	# _setPickerHtml
	#
	#	Set the picker's html
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_setPickerHtml = ->
		section     = storage.getSection()
		lang        = storage.getLanguage()
		userProfile = storage.getUserProfile()
		dictionary  = storage.getDictionary(lang)

		minIndex = (section - 1) * 1000
		maxIndex = section * 1000 - 1

		boxes = {}
		nBoxes = deck.pageSize() / deck.boxSize()

		for boxIndex in [0..nBoxes-1]
			minIndex = (section - 1) * deck.boxSize() + boxIndex * deck.boxSize()
			maxIndex = minIndex + deck.boxSize()
			boxCards = userProfile['langs'][lang].slice(minIndex, maxIndex)
			progressList = parseInt(card['progress']) for card in boxCards
			boxProgress = Math.min(progressList)

			if boxProgress.toString() not in Object.keys(boxes)
				boxes[boxProgress] = []

			boxes[boxProgress].push(boxIndex)

		containerDivs = []
		for progress in Object.keys(boxes)
			rowDivs = []
			for boxIndex in boxes[progress]
				minSampleIndex = (section - 1) * deck.pageSize() + boxIndex * deck.boxSize()
				maxSampleIndex = minSampleIndex + 3
				sampleCards = userProfile['langs'][lang].slice(minSampleIndex, maxSampleIndex)
				sampleWords = (dictionary['dictionary'][card['phrase_id']]['base'] for card in sampleCards)
				sampleStr = sampleWords.join(', ') + "..."
				rowDivHtml = """
					<a class='overview-block-row-link' data-index=#{ boxIndex }><div class='overview-block-row'>
						<div class='overview-block-sample'>#{ sampleStr }</div>
					</div>
				"""
				rowDivs.push(rowDivHtml)

			allRowDivsHtml = rowDivs.join('')

			containerDivHtml = """
				<div class='overview-block'>
					<div class='overview-block-header'>
						HEADER
					</div>
					#{ allRowDivsHtml}
				</div>
			"""

			containerDivs.push(containerDivHtml)

		# Build the picker UI
		allBlocksHtml = containerDivs.join('')

		pickerHtml = """
			#{ allBlocksHtml }
		"""

		$('#overview-content').html(pickerHtml)
		_nav.refreshPage()


	############################################################################
	# _setSection
	#
	############################################################################
	_setSection = (section) ->

		storage.setSection(section)
		$('#overview-display').html(section)

		# Create the picker
		_setPickerHtml()

		$('.overview-block-row-link').click (event) ->
			index = $(this).data('index')
			storage.setBox(index)
			_nav.loadPage('study')

		_nav.refreshPage()


	############################################################################
	# _registerEvents
	#
	#	Register page events
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_registerEvents = ->

		# Clicking on a tile on the overview page
		$('.overview-tile-link').click (event) ->
			event.preventDefault();
			tileId = $(this).data("tile-id")

			_nav.loadPage 'study',
				tileId     : tileId

		$('#overview-btn-left').click (event) ->
			_setSection(storage.getSection() - 1)


		$('#overview-btn-right').click (event) ->
			_setSection(storage.getSection() + 1)


	############################################################################
	# createEmptyProgress
	#
	############################################################################
	_createEmptyProgress = ->

		lang        = storage.getLanguage()
		dictionary  = storage.getDictionary(lang)
		userProfile = storage.getUserProfile()

		phrases = []
		for phraseId in Object.keys(dictionary['dictionary'])
			phrases.push
				phrase_id: phraseId
				progress : 0

		# Update the userProfile in localStorage
		userProfile['langs'][lang] = phrases
		storage.setUserProfile(userProfile)


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

define [
	'utils',
	'storage',
	'nav',
	'css',
	'deck',
	'stack',
	'hbs!../../hbs/src/box-list',
],
(
	utils,
	storage,
	nav,
	css,
	deck,
	stack,
	boxListTemplate,
) ->

	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined
	_nPages = 10

	
	############################################################################
	# UI constants
	#
	############################################################################
	PICKER_TILE_MARGIN = 10


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->

		# Ensure progress is here
		lang = storage.getLanguage()
		userProfile = storage.getUserProfile()
		if lang not in Object.keys(userProfile['langs'])
			_createEmptyProgress()

		# Ensure a section exists
		if not storage.getSection()?
			storage.setSection(1)

		# Build args
		userProfile = storage.getUserProfile()
		dictionary  = storage.getDictionary(lang)
		plan        = storage.getPlan(lang)

		planLength = plan.length
		_nPages     = Math.ceil(planLength / 1000)

		templateArgs =
			sections: [1.._nPages]
		$(".overview-page").html(template(templateArgs))

		_loadBoxList(false)
		_loadNavHeader()

		_nav.showBackBtn "Account", (event) ->
			_nav.loadPage('manage')

		if not userProfile['confirmed']
			_nav.showAlert("You will need to check your email to confirm your email address and fully activate yout account.")

		# Register page events
		_registerEvents()


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->
		_loadBoxList(false)


	_loadNavHeader = ->
		section = storage.getSection()
		sectionInterval = stack.getSectionInterval(section)
		lang = storage.getLanguage()
		plan = storage.getPlan(lang)

		minIndex = sectionInterval['min'] + 1
		maxIndex = Math.min(sectionInterval['max'] + 1, plan.length)

		s = "Cards #{minIndex} through #{maxIndex}"

		if section == 1
			$('.overview-page .arrow-btn-left').hide()
			$('.overview-page .arrow-btn-right').show()
		else if section == _nPages
			$('.overview-page .arrow-btn-left').show()
			$('.overview-page .arrow-btn-right').hide()
		else
			$('.overview-page .arrow-btn-left').show()
			$('.overview-page .arrow-btn-right').show()

		$(".overview-page .interval-text").html(s)


	############################################################################
	# _loadBoxList
	#
	############################################################################
	_loadBoxList = (transition = true) ->
		# Get state
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()
		dictionary  = storage.getDictionary(lang)
		section     = storage.getSection()
		plan        = storage.getPlan(lang)

		# Construct arguments
		templateArgs =
			boxes : stack.getBoxes(plan, dictionary, section, lang, 100)

		# Render template
		$(".overview-page .box-list-#{section}").html(boxListTemplate(templateArgs))
		$(".overview-page .box-list-#{section}").css("width", utils.withUnit(utils.windowWidth(), 'px'))

		$(".overview-page .box-list-container").css("width", utils.withUnit(utils.windowWidth() * 10, 'px'))

		matchWidth = $(".overview-page .box-list-#{section}").css("width")
		#matchHeight = $(".overview-page .box-list-#{section}").css("height") + 100
		$(".overview-page .box-list").css("width", matchWidth)
		#$(".overview-page .box-list").css("height", matchHeight)
		#$(".overview-page .box-list-container").css("height", matchHeight)

		# Register events
		$(".box-list-container .box-div").off('click')
		$(".box-list-#{section} .box-div").click (event) ->
			index = $(this).data('index')
			storage.setBox(index)

			_nav.loadPage('study')

		if transition
			$(".box-list-container").animate { "margin-left": utils.withUnit(-1 * (section - 1) * utils.windowWidth(), 'px') }, 500, ->
				console.log("animate")
		else
			$(".box-list-container").css("margin-left", utils.withUnit(-1 * (section - 1) * utils.windowWidth(), 'px'))


	############################################################################
	# _setPickerHtml
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
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->


		$('.overview-page .arrow-btn-left').click (event) ->
			storage.setSection(storage.getSection() - 1)
			_loadBoxList()
			_loadNavHeader()


		$('.overview-page .arrow-btn-right').click (event) ->
			storage.setSection(storage.getSection() + 1)
			_loadBoxList()
			_loadNavHeader()


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

		loadPage: (template) ->
			_nav = require('nav')
			_loadPage(template)

		refreshPage: ->
			_refreshPage()

	}

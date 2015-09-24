define [
	'utils',
	'storage',
	'api',
	'nav',
	'css',
	'deck',
	'stack',
	'strings',
	'hbs!../../hbs/src/box-list',
],
(
	utils,
	storage,
	api,
	nav,
	css,
	deck,
	stack,
	strings,
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

		# Build args
		userProfile = storage.getUserProfile()
		dictionary  = storage.getDictionary(lang)
		plan        = storage.getPlan(lang)

		planLength = plan.length
		_nPages     = Math.ceil(planLength / 1000)


		documents = storage.getDocuments()
		documentId = storage.getDocumentId()
		doc = documents[documentId]
		templateArgs =
			documentTitle: doc['title']
		$(".overview-page").html(template(templateArgs))

		_loadBoxList(false)

		_nav.showBackBtn "Library", (event) ->
			_nav.loadPage('library')

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


	############################################################################
	# _loadBoxList
	#
	############################################################################
	_loadBoxList = (transition = true) ->
		# Get state
		userProfile = storage.getUserProfile()
		lang        = storage.getLanguage()
		dictionary  = storage.getDictionary(lang)
		plan        = storage.getPlan(lang)
		documentId  = storage.getDocumentId()

		# Construct arguments
		boxes = stack.getBoxes(plan, documentId)
		templateArgs =
			boxes: boxes

		# Render template
		$(".overview-page .box-list").html(boxListTemplate(templateArgs))

		# Do the progress bars
		excerpts = storage.getExcerpts()
		for excerptId in plan[documentId]
			stack.updateProgressBars("box-div-#{ excerptId }", excerpts[excerptId]['phrase_ids'])

		$(".overview-page .box-list").css("width", utils.withUnit(utils.windowWidth(), 'px'))

		$(".overview-page .box-list-container").css("width", utils.withUnit(utils.windowWidth() * 10, 'px'))

		matchWidth = $(".overview-page .box-list").css("width")
		#matchHeight = $(".overview-page .box-list").css("height") + 100
		$(".overview-page .box-list").css("width", matchWidth)
		#$(".overview-page .box-list").css("height", matchHeight)
		#$(".overview-page .box-list-container").css("height", matchHeight)

		# Register events
		$(".box-list-container .box-div").off('click')
		$(".box-list .box-div").click (event) ->
			storage.setExcerptId($(this).data('excerpt-id'))
			_nav.loadPage('study')


	############################################################################
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->
		console.log('events')


	############################################################################
	# _reloadPlan
	#
	############################################################################
	_reloadPlan = ->
		plan_mode = storage.getPlanMode()
		lang = storage.getLanguage()
		api.ensurePlan (json) ->
			if json['success']
				api.ensureExcerptDictionary lang, (json) ->
					console.log(json)
					if json['success']
						if plan_mode == 'example'
							$('.overview-page .add-example-div').show()
						else
							$('.overview-page .add-example-div').hide()
						_loadBoxList()
					else
						# Error getting excerpt dictionary
						$('.login-page .error').html(strings.getString('unexpectedFailure'))
			else
				# Error ensuring plan
				$('.login-page .error').html(strings.getString('unexpectedFailure'))


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

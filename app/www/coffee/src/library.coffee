define ['storage', 'api', 'strings'], (storage, api, strings) ->

	_nav = undefined
	_validLangs = [
		'cy',
		'de',
		'eo',
		'es',
		'fr',
		'he',
		'ru',
		'zh',
	]
	_template = undefined


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->
		_template = template
		userProfile = storage.getUserProfile()
		constants = require('constants')

		planMode = storage.getPlanMode() ? 'example'
		storage.setPlanMode(planMode)

		docs = storage.getDocuments()
		
		templateArgs =
			docs : docs

		console.log(template)

		$(".library-page").html(template(templateArgs))

		$('.library-page .box').click (event) ->
			documentId = $(this).data('document-id')
			storage.setDocumentId(documentId)
			_nav.loadPage('overview')

		_nav.showBackBtn "Logout", (event) ->
			storage.logout()
			_nav.loadPage('login')

		$('.library-page .add-doc-btn').click (event) ->
			title = $('.library-page .add-doc-title-input').val()
			text = $('.library-page .add-doc-text-input').val()
			console.log(text)
			api.addDocument title, text, (json) ->
				if json['success']
					storage.setDocumentId(json['result'])	
					api.getPlan (json) ->
						if json['success']
							lang = storage.getLanguage()
							api.ensureExcerptDictionary lang, (json) ->
								if json['success']
									_nav.loadPage('overview')
								else
									# Error getting excerpt dictionary
									$('.login-page .error').html(strings.getString('unexpectedFailure'))
						else
							# Error ensuring plan
							$('.login-page .error').html(strings.getString('unexpectedFailure'))
				else
					# Error adding document
					$('.login-page .error').html(strings.getString('unexpectedFailure'))


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->
		console.log("refresh")


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

define [
	'jquery',
	'hbs!../../hbs/src/app',
	'hbs!../../hbs/src/alert',
	'hbs!../../hbs/src/modal',
	'pageview',
	'utils',
	'constants',
	'storage',
],
(
	$,
	appTemplate,
	alertTemplate,
	modalTemplate,
	pageview,
	utils,
	constants,
	storage,
) ->

	############################################################################
	# _initPages
	#
	############################################################################
	_initPages = ->
		$("body").html(appTemplate({ pages: constants.pages }))

		_hideAlert()
		_hideModal()


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (page) ->
		template = constants.templateMap[page]

		constants.pageActionMap[page]['load'](template)

		_hideAlert()

		storage.setPage(page)		

		pageview.formatPageDimensions(page)


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->
		page = storage.getPage()

		constants.pageActionMap[page]['refresh']()

		pageview.formatPageDimensions(page)


	############################################################################
	# _showAlert
	#
	############################################################################
	_showAlert = (message) ->
		$(".alert-div").html(alertTemplate({ message: message }))
		$(".alert-div").css("visibility", "visible");

		console.log(pageview.getAlertHeight())
		console.log(utils.withUnit(-1 * pageview.getAlertHeight(), 'px'))

		$(".alert-div").css("margin-top", utils.withUnit(-1 * pageview.getAlertHeight(), 'px'))
		$(".alert-div").show()

		$(".alert-div").animate { "margin-top": "0px" }, 500, ->
			console.log("create")
			$(".alert-div .alert-btn").click (event) ->
				console.log("click it")
				_hideAlert()


	############################################################################
	# _hideAlert
	#
	############################################################################
	_hideAlert = ->
		$(".alert-div").css("margin-top", "0px")

		$(".alert-div").animate { "margin-top": utils.withUnit(-1 * pageview.getAlertHeight(), 'px') }, 500, ->
			$(".alert-div").hide()


	############################################################################
	# _showModal
	#
	############################################################################
	_showModal = (html) ->
		$(".modal-div").html(modalTemplate({ html: html }))
		$(".modal-div").css("visibility", "visible");
		$(".modal-div").show()


	############################################################################
	# _hideModal
	#
	############################################################################
	_hideModal = ->
		$(".modal-div").hide()


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		initPages: ->
			_initPages()

		loadPage: (page) ->
			_loadPage(page)

		refreshPage: ->
			_refreshPage()

		showAlert: (message) ->
			_showAlert(message)

		hideAlert: ->
			_hideAlert()

		showModal: (html) ->
			_showModal(html)

		hideModal: ->
			_hideModal()

	}
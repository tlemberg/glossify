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
	# Module properties
	#
	############################################################################
	_modalTimeout = undefined


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

		_hideAlert()
		_hideBackBtn()

		constants.pageActionMap[page]['load'](template)

		storage.setPage(page)

		pageview.formatPageDimensions(page)


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->
		page = storage.getPage()

		constants.pageActionMap[page]['refresh']()

		pageview.formatPageDimensions(page, false)


	############################################################################
	# _showAlert
	#
	############################################################################
	_showAlert = (message) ->
		$(".alert-div").finish()

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
	# _showBackBtn
	#
	############################################################################
	_showBackBtn = (text, clickEvent) ->
		$(".header .back-btn").html(text)
		$(".header .back-btn").css("visibility", "visible");

		$(".header .back-btn").off('click')
		$(".header .back-btn").click(clickEvent)


	############################################################################
	# _hideBackBtn
	#
	############################################################################
	_hideBackBtn = ->
		$(".header .back-btn").css("visibility", "hidden");


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
	_showModal = (html, type, delay) ->
		templateArgs =
			html   : html
			isAjax : type == 'ajax'
			isAlert: type == 'alert'

		$(".modal-div").html(modalTemplate(templateArgs))
		$(".modal-div").css("visibility", "visible");

		$(".modal-div .btn").click (event) ->
			_hideModal()

		if _modalTimeout?
			clearTimeout(_modalTimeout)
		_modalTimeout = setTimeout (-> $(".modal-div").fadeIn(250)), delay


	############################################################################
	# _hideModal
	#
	############################################################################
	_hideModal = ->
		if _modalTimeout?
			clearTimeout(_modalTimeout)
			
		$(".modal-div").fadeOut(250)


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

		showModal: (html, type, delay) ->
			_showModal(html, type, delay)

		hideModal: ->
			_hideModal()

		showBackBtn: (text, clickEvent) ->
			_showBackBtn(text, clickEvent)

	}
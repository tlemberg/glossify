define [
	'strings',
	'storage',
	'utils',
	'api',
	'nav',
	'css',
	'pageview',
],
(
	strings,
	storage,
	utils,
	api,
	nav,
	css,
) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined
	_config = undefined


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->

		templateArgs =
			lockdown: _config.lockdown
		$(".signup-page").html(template(templateArgs))

		_registerEvents()

		_nav.showBackBtn "Back", (event) ->
			_nav.loadPage('login')


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = ->
		console.log("refresh")


	############################################################################
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->
		$('.signup-page .signup-btn').click (event) ->

			if _config.lockdown?

				# Collect inputs from the UI
				email     = $('.signup-page .email-input').val()

				# Validate inputs
				if not _validateEmail(email)
					_nav.showAlert(strings.getString('invalidEmail'))
				else
					api.requestAccess email, (json) ->
						_nav.showAlert("Your request for an account has been received. We will contact you via email if you are approved.")

			else

				# Collect inputs from the UI
				email     = $('.signup-page .email-input').val()
				password1 = $('.signup-page .password-input-1').val()
				password2 = $('.signup-page .password-input-2').val()

				# Validate inputs
				if not _validateEmail(email)
					_nav.showAlert(strings.getString('invalidEmail'))
				# Validate password
				else if not _validatePassword(password1, password2)
					_nav.showAlert(strings.getString('invalidPassword'))
				else
					api.createUser email, password1, (json) ->
						console.log(json)

						if json['success']
							# Attempt to fetch an access token via the API
							api.authenticateUser email, password1, (json) ->
								if json['success']
									storage.setLanguage('fr') # TODO: generalize

									api.ensureDictionary 'fr', (json) ->
										if json['success']
											_nav.loadPage('overview')
										else
											# Error ensuring dictionary
											_nav.showAlert(strings.getString('unexpectedFailure'))
						else
							_nav.showAlert("error creating user")

		$('.signup-page input').keydown (event) ->
			if event.keyCode == 13
				$('.signup-page .signup-btn').click()


	############################################################################
	# _validateEmail
	#
	############################################################################
	_validateEmail = (email) ->
		email.match(/^([\w.-]+)@([\w.-]+)\.([a-zA-Z.]{2,6})$/i)?


	############################################################################
	# _validatePassword
	#
	############################################################################
	_validatePassword = (password1, password2) ->
		password1 != '' and password1 == password2


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		refreshPage: ->
			_refreshPage()

		loadPage: (template) ->
			_nav = require('nav')
			_config = require('config')
			_loadPage(template)

	}

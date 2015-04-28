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


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (template) ->

		$(".signup-page").html(template())

		_registerEvents()


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

			console.log("HIHIHI")

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
		password1 == password2


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		refreshPage: ->
			_refreshPage()

		loadPage: (template) ->
			_nav = require('nav')
			_loadPage(template)

	}

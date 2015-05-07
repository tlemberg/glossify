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

		$(".login-page").html(template())

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

		# When the login button is clicked
		$('.login-page .login-btn').click (event) ->

			# Extract email and password
			email    = $('.login-page #email-input').val()
			password = $('.login-page #password-input').val()

			# Attempt to fetch an access token via the API
			api.authenticateUser email, password, (json) ->
				if json['success']
					storage.setLanguage('fr') # TODO: generalize

					api.ensureDictionary 'fr', (json) ->
						if json['success']
							console.log("success")
							_nav.loadPage('overview')
						else
							# Error ensuring dictionary
							$('.login-page .error').html(strings.getString('unexpectedFailure'))
				else
					# Error authenticating user
					#$('.login-page .error').html(strings.getString('loginFailed'))
					_nav.showAlert(strings.getString('loginFailed'))

		# When the signup button is clicked
		$('.login-page .signup-btn').click (event) ->
			console.log("clicked")
			_nav.loadPage('signup')


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

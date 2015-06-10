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
		$(".login-page").html(template(templateArgs))

		if utils.getUrlParameter('action') == 'activationsuccessful' and !storage.getAccountConfirmed()?
			_nav.showAlert("Your have succesfully confirmed your account")
			storage.setAccountConfirmed(true)

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
							
							api.getProgress (json) ->
								if json['success']

									api.getPlan (json) ->

										if json['success']
											_nav.loadPage('overview')
										else
											# Error ensuring plan
											$('.login-page .error').html(strings.getString('unexpectedFailure'))
								else
									# Error ensuring progress
									$('.login-page .error').html(strings.getString('unexpectedFailure'))
						else
							# Error ensuring dictionary
							$('.login-page .error').html(strings.getString('unexpectedFailure'))
				else
					# Error authenticating user
					#$('.login-page .error').html(strings.getString('loginFailed'))
					_nav.showAlert(strings.getString('loginFailed'))

		# When the signup button is clicked
		$('.login-page .signup-btn').click (event) ->
			_nav.loadPage('signup')


		$('.login-page input').keydown (event) ->
			if event.keyCode == 13
				$('.login-page .login-btn').click()


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

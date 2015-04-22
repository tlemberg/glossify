define ['strings', 'storage', 'utils', 'api', 'nav', 'css'], (strings, storage, utils, api, nav, css) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined


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
		_registerEvents()


	############################################################################
	# _loadPage
	#
	#	Load the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_loadPage = (params) ->
		console.log("load")


	############################################################################
	# _refreshPage
	#
	#	Refresh the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_refreshPage = ->
		console.log("refresh")


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

		# When the login button is clicked
		$('#login-btn').click (event) ->

			# Extract email and password
			email = $('#login-email-input').val()
			password = $('#login-password-input').val()

			# Attempt to fetch an access token via the API
			api.authenticateUser email, password, (json) ->
				if json['success']
					storage.setLanguage('fr') # TODO: generalize

					api.ensureDictionary 'fr', (json) ->
						if json['success']
							_nav.loadPage 'overview'
						else
							# Error ensuring dictionary
							$('#login-error').html(strings.getString('unexpectedFailure'))
				else
					# Error authenticating user
					$('#login-error').html(strings.getString('loginFailed'))

		# When the signup button is clicked
		$('#login-signup-btn').click (event) ->
			_nav.loadPage('signup')


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

define ['strings', 'utils', 'nav', 'css', 'api'], (strings, utils, nav, css, api) ->

	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined


	############################################################################
	# _preloadPage
	#
	############################################################################
	_preloadPage = (userProfile, dictionary, params) ->
		_registerEvents()


	############################################################################
	# _refreshPage
	#
	############################################################################
	_refreshPage = (userProfile, dictionary, params) ->
		console.log("refresh")


	############################################################################
	# _loadPage
	#
	############################################################################
	_loadPage = (userProfile, dictionary, params) ->
		console.log("load")


	############################################################################
	# _registerEvents
	#
	############################################################################
	_registerEvents = ->
		$('#signup-btn').click (event) ->

			# Collect inputs from the UI
			email     = $('#signup-email-input').val()
			password1 = $('#signup-password-input').val()
			password2 = $('#signup-retype-password-input').val()

			# Validate inputs
			if not _validateEmail(email)
				$('#signup-error').html(strings.getString('invalidEmail'))
			# Validate password
			else if not _validatePassword(password1, password2)
				$('#signup-error').html(strings.getString('invalidPassword'))
			else
				$('#signup-error').html('')

			# Call the API
			api.createUser email, password1, (json) ->
				console.log(json)


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


		########################################################################
		# preloadStudyPage
		#
		#	Generates the elements of the page that only need to be built once
		#
		# Parameters:
		#
		#	userProfile: userProfile hash
		#	dictionary : dictionary hash
		#	params     : extra parameters
		#	
		# Returns:
		#	Nothing
		########################################################################
		preloadPage: (userProfile, dictionary, params) ->
			_nav = require('nav')

			_preloadPage(userProfile, dictionary, params)


		########################################################################
		# refreshStudyPage
		#
		#	Adjusts the elements of the page every time it changes size
		#
		# Parameters:
		#
		#	userProfile: userProfile hash
		#	dictionary : dictionary hash
		#	params     : extra parameters
		#	
		# Returns:
		#	Nothing
		########################################################################
		refreshPage: (userProfile, dictionary, params) ->
			_refreshPage(userProfile, dictionary, params)


		########################################################################
		# loadStudyPage
		#
		#	Adjusts the elements of the page when it is navigated to in the app
		#
		# Parameters:
		#
		#	userProfile: userProfile hash
		#	dictionary : dictionary hash
		#	params     : extra parameters
		#	
		# Returns:
		#	Nothing
		########################################################################
		loadPage: (userProfile, dictionary, params) ->
			_loadPage(userProfile, dictionary, params)


	}

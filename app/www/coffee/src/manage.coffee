define ['utils', 'nav', 'css'], (utils, nav, css) ->

	_nav = undefined

	# UI constants
	PICKER_TILE_MARGIN = 10


	_preloadPage = (userProfile, dictionary, params) ->
		_registerEvents()


	# Render the overview page
	_refreshPage = (userProfile, dictionary, params) ->
		console.log("refresh")


	_loadPage = (userProfile, dictionary, params) ->
		console.log("load")


	_registerEvents = ->
		console.log("register")


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

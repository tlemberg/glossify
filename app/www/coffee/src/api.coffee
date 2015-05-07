define ['utils', 'storage', 'nav', 'strings'], (utils, storage, nav, strings) ->


	############################################################################
	# Module properties
	#
	############################################################################
	URL_BASE = 'http://52.10.65.123:5000/api/'
	_nav = undefined

	############################################################################
	# _apiUrl
	#
	############################################################################
	_apiUrl = (url, authenticated, params) ->

		params ||= {}

		# Define authentication params
		if authenticated
			params['email']      = storage.getUserProfile()['email']
			params['auth_token'] = storage.getAccessToken()

		# Create strings for the GET parameters
		paramStr = ("#{ k }=#{ v }" for k, v of params).join('&')

		# Return the URL
		if paramStr
			"#{ URL_BASE }#{ url }?#{ paramStr }"
		else
			"#{ URL_BASE }#{ url }"


	############################################################################
	# _createUser
	#
	#	Creates a user on the server and executes a response handler
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_createUser = (email, password, handler) ->
		_nav.showModal("Creating user", "ajax", 1000)

		# Send the remote call
		$.ajax
			url      : _apiUrl('create-user')
			method   : "POST"
			data     : { email: email, password: password }
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _authenticateUser
	#
	#	Requests an access token and userProfile, which are then placed in
	#	localStorage if sucessful. A handler is executed in failure or success
	#
	# Parameters:
	#
	#	email		the user's email
	#	password	the user's password
	#	handler		the handler to execute on success/failure of the remote call
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_authenticateUser = (email, password, handler) ->
		_nav.showModal("Signing in", "ajax", 1000)
		$.ajax
			url      : _apiUrl('authenticate-user')
			method   : "POST"
			data     : { email: email, password: password }
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success']
					storage.setAccessToken(json['result']['token'])
					storage.setUserProfile(json['result']['userProfile'])
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _fetchDictionary
	#
	#	Requests a dictionary from the server and executes a response handler
	#
	# Parameters:
	#
	#	lang		the 2-digit language code for the dictionary to request
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_fetchDictionary = (lang, handler) ->
		_nav.showModal("Downloading dictionary", "ajax", 1000)

		# Prepare some variables
		token = storage.getAccessToken()

		# Send the remote call
		$.ajax
			url      : "http://52.10.65.123:5000/api/get-dictionary/#{ lang }?auth_token=#{ token }"
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success'] is 1
					dictionary = json['result']
					storage.setDictionary(lang, dictionary)

				# Refresh the page now that we have made an attempt at fetching the dictionary
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _updateUserProfile
	#
	#	Updates a userProfile on the server and executes a response handler
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_updateUserProfile = (handler) ->
		_nav.showModal("Updating user profile", "ajax", 1000)

		# Prepare some variables
		userProfile = storage.getUserProfile()
		email = userProfile['email']
		token = storage.getAccessToken()

		# Send the remote call
		$.ajax
			url      : "http://52.10.65.123:5000/api/update-progress/#{ email }?auth_token=#{ token }"
			method   : 'post'
			data     : { cards: cards }
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success'] is 1
					dictionary = json['result']

				# Refresh the page now that we have made an attempt at fetching the dictionary
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _ensureDictionary
	#
	#	Ensures that a dictionary exists in local storage. If there is already
	#	an up-to-date version of the dictionary in localStorage, then this
	#	method takes no action and executes the handler. Otherwise, it fetches
	#	a new copy of the dictionary, stores it in localStorage, and then
	#	executes the handler.
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_ensureDictionary = (lang, handler) ->
		# Attempt to get the dictionary from memory
		dictionary = storage.getDictionary(lang)

		if dictionary?
			handler
				success: 1
				result : dictionary
		else
			_fetchDictionary(lang, handler)


	############################################################################
	# _addLanguage
	#
	#	Adds a language on the server and executes a response handler
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing. Executes the response handler.
	#
	############################################################################
	_addLanguage = (lang, handler) ->

		# Send the remote call
		$.ajax
			url      : _apiUrl("add-language/#{ lang }", authenticated = true)
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				handler(json)


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		createUser: (email, password, handler) ->
			_nav = require("nav")
			_createUser(email, password, handler)


		authenticateUser: (email, password, handler) ->
			_nav = require("nav")
			_authenticateUser(email, password, handler)


		addLanguage: (lang, handler) ->
			_nav = require("nav")
			_addLanguage(lang, handler)


		ensureDictionary: (lang, handler) ->
			_nav = require("nav")
			_ensureDictionary(lang, handler)


		updateUserProfile: (handler) ->
			_nav = require("nav")
			_updateUserProfile(handler)


		apiSummary: ->
			'createUser':
				func: this.createUser
				params: ['email', 'password']
			'authenticateUser':
				func: this.authenticateUser
				params: ['email', 'password']
			'addLanguage':
				func: this.addLanguage
				params: ['lang']
			'updateUserProfile':
				func: this.updateUserProfile
				params: []
			
	}
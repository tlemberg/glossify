define ['utils', 'storage', 'nav', 'strings', 'config'], (utils, storage, nav, strings, config) ->


	############################################################################
	# Module properties
	#
	############################################################################
	URL_BASE = config.apiUrl
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

		console.log(url)

		# Return the URL
		if paramStr
			"#{ URL_BASE }#{ url }?#{ paramStr }"
		else
			"#{ URL_BASE }#{ url }"


	############################################################################
	# _createUser
	#
	############################################################################
	_createUser = (email, password, handler) ->
		_nav.showModal("Creating user", "ajax", 100)

		console.log(_apiUrl('create-user'))

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
	############################################################################
	_authenticateUser = (email, password, handler) ->
		_nav.showModal("Signing in", "ajax", 100)
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
	# _requestAccess
	#
	############################################################################
	_requestAccess = (email, handler) ->
		_nav.showModal("Requesting access", "ajax", 100)
		$.ajax
			url      : _apiUrl('request-access')
			method   : "POST"
			data     : { email: email}
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _fetchDictionary
	#
	############################################################################
	_fetchDictionary = (lang, handler) ->
		_nav.showModal("Downloading dictionary", "ajax", 100)

		# Prepare some variables
		token = storage.getAccessToken()

		# Send the remote call
		$.ajax
			url      : _apiUrl("get-dictionary/#{ lang }", authenticated = true)
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				console.log(json)
				console.log(Object.keys(json['result']['dictionary']).length)
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
	############################################################################
	_updateUserProfile = (handler) ->
		_nav.showModal("Updating user profile", "ajax", 100)

		# Prepare some variables
		userProfile = storage.getUserProfile()
		email = userProfile['email']
		token = storage.getAccessToken()

		# Send the remote call
		$.ajax
			url      : _apiUrl("update-progress/#{ email }", authenticated = true)
			method   : 'post'
			data     : { cards: cards }
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success']
					dictionary = json['result']

				# Refresh the page now that we have made an attempt at fetching the dictionary
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _ensureDictionary
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
	############################################################################
	_addLanguage = (lang, handler) ->
		# Show the modal after a certain amount of load time
		_nav.showModal("Adding language to your library", "ajax", 1000)

		# Send the query
		$.ajax
			url      : _apiUrl("add-language/#{ lang }", authenticated = true)
			method   : "POST"
			data     : {}
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success']
					userProfile = storage.getUserProfile()
					userProfile['langs'].push(lang)
					console.log(userProfile)
					storage.setUserProfile(userProfile)
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _updateProgress
	#
	############################################################################
	_updateProgress = (handler) ->
		# Show the modal after a certain amount of load time
		_nav.showModal("Saving your progress history", "ajax", 1000)

		# Construct the data
		data =
			lang            : storage.getLanguage()
			progress_updates: JSON.stringify(storage.getProgressUpdates())

		# Send the query
		$.ajax
			url      : _apiUrl('update-progress', authenticated = true)
			method   : "POST"
			data     : data
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success']
					storage.clearProgressUpdates()
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _getProgress
	#
	############################################################################
	_getProgress = (handler) ->
		# Show the modal after a certain amount of load time
		_nav.showModal("Downloading your progress history", "ajax", 1000)

		# Construct the data
		lang = storage.getLanguage()
		data =
			lang: lang

		# Send the query
		$.ajax
			url      : _apiUrl('get-progress', authenticated = true)
			method   : "POST"
			data     : data
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				_nav.hideModal()
				if json['success']
					storage.setProgressObject(lang, json['result']['progress'])
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _getPlan
	#
	############################################################################
	_getPlan = (handler) ->
		# Show the modal after a certain amount of load time
		_nav.showModal("Downloading lesson plans", "ajax", 100)

		# Construct the data
		lang = storage.getLanguage()
		data =
			lang: lang

		# Send the query
		$.ajax
			url      : _apiUrl('get-plan', authenticated = true)
			method   : "POST"
			data     : data
			dataType : 'json'
			timeout  : 10 * 1000
			success  : (json) ->
				console.log(json)
				_nav.hideModal()
				if json['success']
					storage.setPlan(lang, json['result'])
				handler(json)
			error    : (jqXHR, textStatus, thownError) ->
				_nav.showModal(strings.getString("ajaxError"), "alert")


	############################################################################
	# _ensurePlan
	#
	############################################################################
	_ensurePlan = (handler) ->
		# Attempt to get the dictionary from memory
		lang = storage.getLanguage()
		plan = storage.getPlan(lang)

		if plan?
			handler
				success: 1
				result : plan
		else
			_getPlan(handler)


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

		requestAccess: (email, handler) ->
			_nav = require("nav")
			_requestAccess(email, handler)


		addLanguage: (lang, handler) ->
			_nav = require("nav")
			_addLanguage(lang, handler)


		ensureDictionary: (lang, handler) ->
			_nav = require("nav")
			_ensureDictionary(lang, handler)


		updateUserProfile: (handler) ->
			_nav = require("nav")
			_updateUserProfile(handler)


		updateProgress: (handler) ->
			_nav = require("nav")
			_updateProgress(handler)


		getProgress: (handler) ->
			_nav = require("nav")
			_getProgress(handler)


		getPlan: (handler) ->
			_nav = require("nav")
			_getPlan(handler)


		ensurePlan: (handler) ->
			_nav = require("nav")
			_ensurePlan(handler)


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
define ['utils'], (utils) ->


	############################################################################
	# Storage key constants
	#
	############################################################################
	ACCESS_TOKEN_KEY = 'token'
	USER_PROFILE_KEY = 'user_profile'
	DICTIONARY_KEY   = 'dictionary'
	LANGUAGE_KEY     = 'lang'


	############################################################################
	# Generic helpers
	#
	############################################################################
	_getLocalStorageItem = (k) ->
		JSON.parse(localStorage.getItem(k))


	_setLocalStorageItem = (k, v) ->
		localStorage.setItem(k, JSON.stringify(v))


	_removeLocalStorageItem = (k) ->
		localStorage.removeItem(k)


	############################################################################
	# Key-specific getters and setters
	#
	############################################################################
	_getAccessToken = ->
		_getLocalStorageItem(ACCESS_TOKEN_KEY)


	_setAccessToken = (v) ->
		_setLocalStorageItem(ACCESS_TOKEN_KEY, v)


	_getUserProfile = ->
		_getLocalStorageItem(USER_PROFILE_KEY)


	_setUserProfile = (v) ->
		_setLocalStorageItem(USER_PROFILE_KEY, v)


	_getLanguage = ->
		_getLocalStorageItem(LANGUAGE_KEY)


	_setLanguage = (v) ->
		_setLocalStorageItem(LANGUAGE_KEY, v)


	_getDictionary = (lang) ->
		_getLocalStorageItem("dictionary_#{ lang }")


	_setDictionary = (lang, v) ->
		_setLocalStorageItem("dictionary_#{ lang }", v)


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		getAccessToken: ->
			_getAccessToken()


		setAccessToken: (v) ->
			_setAccessToken(v)


		getUserProfile: ->
			_getUserProfile()


		setUserProfile: (v) ->
			_setUserProfile(v)


		getLanguage: ->
			_getLanguage()


		_setLanguage: (v) ->
			_setLanguage(v)


		getDictionary: (lang) ->
			_getDictionary(lang)


		setDictionary: (lang, v) ->
			_setDictionary(lang, v)

	}


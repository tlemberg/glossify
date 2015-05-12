define ['utils'], (utils) ->


	############################################################################
	# Storage key constants
	#
	############################################################################
	PAGE_KEY         = 'page'
	ACCESS_TOKEN_KEY = 'token'
	USER_PROFILE_KEY = 'user_profile'
	DICTIONARY_KEY   = 'dictionary'
	LANGUAGE_KEY     = 'lang'
	SECTION_KEY      = 'section'
	BOX_KEY          = 'box'
	ACCOUNT_CONFIRMED_KEY = 'account_confirmed'


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
	# Special functions
	#
	############################################################################
	_logout = ->
		_removeLocalStorageItem(PAGE_KEY)
		_removeLocalStorageItem(ACCESS_TOKEN_KEY)
		_removeLocalStorageItem(USER_PROFILE_KEY)
		_removeLocalStorageItem(DICTIONARY_KEY)
		_removeLocalStorageItem(LANGUAGE_KEY)
		_removeLocalStorageItem(SECTION_KEY)
		_removeLocalStorageItem(BOX_KEY)


	############################################################################
	# Key-specific getters and setters
	#
	############################################################################
	_getPage = ->
		_getLocalStorageItem(PAGE_KEY)


	_setPage = (v) ->
		_setLocalStorageItem(PAGE_KEY, v)


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


	_getSection = ->
		_getLocalStorageItem(SECTION_KEY)


	_setSection = (v) ->
		_setLocalStorageItem(SECTION_KEY, v)


	_getBox = ->
		_getLocalStorageItem(BOX_KEY)


	_setBox = (v) ->
		_setLocalStorageItem(BOX_KEY, v)


	_getAccountConfirmed = ->
		_getLocalStorageItem(ACCOUNT_CONFIRMED_KEY)


	_setAccountConfirmed = (v) ->
		_setLocalStorageItem(ACCOUNT_CONFIRMED_KEY, v)


	_isLoggedIn = ->
		userProfile = _getUserProfile()
		lang        = _getLanguage()
		if userProfile? and lang?
			dictionary  = _getDictionary()
			if dictionary?
				return true
		return false



	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		logout: ->
			_logout()

		getPage: ->
			_getPage()

		setPage: (v) ->
			_setPage(v)

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

		setLanguage: (v) ->
			_setLanguage(v)

		getDictionary: (lang) ->
			_getDictionary(lang)

		setDictionary: (lang, v) ->
			_setDictionary(lang, v)

		getSection: ->
			_getSection()

		setSection: (v) ->
			_setSection(v)

		getBox: ->
			_getBox()

		setBox: (v) ->
			_setBox(v)

		getAccountConfirmed: ->
			_getAccountConfirmed()

		setAccountConfirmed: (v) ->
			_setAccountConfirmed(v)

		isLoggedIn: ->
			_isLoggedIn()

	}


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
	PROGRESS_KEY     = 'progress'
	STUDY_MODE_KEY   = 'study_mode'
	STUDY_ORDER_KEY  = 'study_order'
	SHOW_PRON_KEY    = 'show_pron'
	PROGRESS_UPDATES_KEY  = 'card_updates'
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
		_removeLocalStorageItem(LANGUAGE_KEY)
		_removeLocalStorageItem(SECTION_KEY)
		_removeLocalStorageItem(BOX_KEY)
		_removeLocalStorageItem(STUDY_MODE_KEY)
		_removeLocalStorageItem(STUDY_ORDER_KEY)

		constants = require('constants')

		for lang in Object.keys(constants.langMap)
			_removeDictionary(lang)
			_removePlan(lang)
			_removeProgress(lang)

		_clearProgressUpdates()


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


	_removeDictionary = (lang) ->
		_removeLocalStorageItem("dictionary_#{ lang }")


	_getSection = ->
		_getLocalStorageItem(SECTION_KEY)


	_setSection = (v) ->
		_setLocalStorageItem(SECTION_KEY, v)


	_getBox = ->
		_getLocalStorageItem(BOX_KEY)


	_setBox = (v) ->
		_setLocalStorageItem(BOX_KEY, v)


	_getStudyMode = ->
		_getLocalStorageItem(STUDY_MODE_KEY)


	_setStudyMode = (v) ->
		_setLocalStorageItem(STUDY_MODE_KEY, v)


	_getStudyOrder= ->
		_getLocalStorageItem(STUDY_ORDER_KEY)


	_setStudyOrder = (v) ->
		_setLocalStorageItem(STUDY_ORDER_KEY, v)


	_getShowPron = ->
		_getLocalStorageItem(SHOW_PRON_KEY)


	_setShowPron = (v) ->
		_setLocalStorageItem(SHOW_PRON_KEY, v)


	_getAccountConfirmed = ->
		_getLocalStorageItem(ACCOUNT_CONFIRMED_KEY)


	_setAccountConfirmed = (v) ->
		_setLocalStorageItem(ACCOUNT_CONFIRMED_KEY, v)


	_clearProgressUpdates = ->
		lang = _getLanguage()
		_removeLocalStorageItem("progress_updates_#{ lang }")


	_getProgressUpdates = ->
		lang = _getLanguage()
		_getLocalStorageItem("progress_updates_#{ lang }")


	_addProgressUpdate = (phraseId, progressValue, studyMode) ->

		lang = _getLanguage()
		studyMode ?= 'defs'

		# Get the progressUpdates hash, defaulting to an empty hash
		progressUpdates = _getProgressUpdates()
		if !progressUpdates?
			progressUpdates = {
				'defs': {},
				'pron': {},
			}

		# Modify the hash
		progressUpdates[studyMode][phraseId] = progressValue

		# Store the modified value locally
		_setLocalStorageItem("progress_updates_#{ lang }", progressUpdates)


	_setProgressObject = (lang, v) ->
		_setLocalStorageItem("progress_#{ lang }", v)


	_getProgress = (phraseId, studyMode) ->

		studyMode ?= 'defs'

		lang = _getLanguage()
		progress = _getLocalStorageItem("progress_#{ lang }")
		progress[studyMode][phraseId] ? 0


	_setProgress = (phraseId, progressValue, studyMode) ->

		studyMode ?= 'defs'

		lang = _getLanguage()
		progress = _getLocalStorageItem("progress_#{ lang }") ? {}
		progress[studyMode][phraseId] = progressValue
		_setLocalStorageItem("progress_#{ lang }", progress)
		_addProgressUpdate(phraseId, progressValue, studyMode)

	_removeProgress = (lang) ->
		_removeLocalStorageItem("progress_#{ lang }")


	_getPlan = (lang) ->
		_getLocalStorageItem("plan_#{ lang }")


	_setPlan = (lang, v) ->
		_setLocalStorageItem("plan_#{ lang }", v)


	_removePlan = (lang) ->
		_removeLocalStorageItem("plan_#{ lang }")


	_isLoggedIn = ->
		userProfile = _getUserProfile()
		lang        = _getLanguage()

		console.log(userProfile)
		console.log(lang)

		if userProfile? and lang?
			dictionary  = _getDictionary(lang)
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
			constants = require('constants')
			for dictLang in Object.keys(constants.langMap)
				_removeDictionary(dictLang)
			_setDictionary(lang, v)

		getSection: ->
			_getSection()

		setSection: (v) ->
			_setSection(v)

		getBox: ->
			_getBox()

		setBox: (v) ->
			_setBox(v)

		getStudyMode: ->
			_getStudyMode()

		setStudyMode: (v) ->
			_setStudyMode(v)

		getStudyOrder: ->
			_getStudyOrder()

		setStudyOrder: (v) ->
			_setStudyOrder(v)

		getShowPron: ->
			_getShowPron()

		setShowPron: (v) ->
			_setShowPron(v)

		getAccountConfirmed: ->
			_getAccountConfirmed()

		setAccountConfirmed: (v) ->
			_setAccountConfirmed(v)

		getProgressUpdates: ->
			_getProgressUpdates()

		clearProgressUpdates: ->
			_clearProgressUpdates()

		addProgressUpdate: (phraseId, progressValue) ->
			_addProgressUpdate(phraseId, progressValue)

		getProgress: (phraseId, studyMode) ->
			_getProgress(phraseId, studyMode)

		setProgress: (phraseId, progressValue, studyMode) ->
			_setProgress(phraseId, progressValue, studyMode)

		setProgressObject: (lang, v) ->
			_setProgressObject(lang, v)

		getPlan: (lang) ->
			_getPlan(lang)

		setPlan: (lang, v) ->
			_setPlan(lang, v)

		isLoggedIn: ->
			_isLoggedIn()

	}


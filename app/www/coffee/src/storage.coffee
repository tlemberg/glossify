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
	PLAN_MODE_KEY    = 'plan_mode'
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
		_removeLocalStorageItem(PLAN_MODE_KEY)

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


	_getPlanMode = ->
		_getLocalStorageItem(PLAN_MODE_KEY)


	_setPlanMode = (v) ->
		_setLocalStorageItem(PLAN_MODE_KEY, v)


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
		progressUpdates = _getLocalStorageItem("progress_updates_#{ lang }")

		if !progressUpdates?
			progressUpdates = {
				'defs': {},
				'pron': {},
			}

		progressUpdates


	_addProgressUpdate = (phraseId, progressValue, studyMode) ->

		lang = _getLanguage()
		studyMode ?= 'defs'

		progressUpdates = _getProgressUpdates()

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
		planMode = _getPlanMode()
		_getLocalStorageItem("plan_#{ lang }_#{ planMode }")


	_setPlan = (lang, v) ->
		planMode = _getPlanMode()
		_setLocalStorageItem("plan_#{ lang }_#{ planMode }", v)


	_removePlan = (lang) ->
		_removeLocalStorageItem("plan_#{ lang }_frequency")
		_removeLocalStorageItem("plan_#{ lang }_example")


	_isLoggedIn = ->
		userProfile = _getUserProfile()
		lang        = _getLanguage()

		if userProfile? and lang?
			dictionary  = _getDictionary(lang)
			if dictionary?
				return true
		return false


	_deleteCard = (deckIndex, phraseId) ->
		lang = _getLanguage()
		plan = _getPlan(lang)
		phraseIds = plan[deckIndex]['phraseIds']
		newPhraseIds = []
		for matchedPhraseId in phraseIds
			if phraseId != matchedPhraseId
				newPhraseIds.push(matchedPhraseId)
		plan[deckIndex]['phraseIds'] = newPhraseIds
		_setPlan(lang, plan)

		deckId = plan[deckIndex]['deckId']
		_addDeckUpdate(deckId, newPhraseIds)


	_addDeckUpdate = (deckId, phraseIds) ->

		# Get the progressUpdates hash, defaulting to an empty hash
		deckUpdates = _getDeckUpdates()
		if !deckUpdates?
			deckUpdates = {}

		# Modify the hash
		deckUpdates[deckId] = phraseIds

		# Store the modified value locally
		_setDeckUpdates(deckUpdates)


	_getDeckUpdates = ->
		deckUpdates = _getLocalStorageItem("deck_updates")
		if !deckUpdates?
			deckUpdates = {}
		deckUpdates


	_setDeckUpdates = (v) ->
		_setLocalStorageItem("deck_updates", v)


	_clearDeckUpdates = ->
		_removeLocalStorageItem("deck_updates")


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

		getPlanMode: ->
			_getPlanMode()

		setPlanMode: (v) ->
			_setPlanMode(v)

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

		getDeckUpdates: ->
			_getDeckUpdates()

		clearDeckUpdates: ->
			_clearDeckUpdates()

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

		deleteCard: (deckIndex, phraseId) ->
			_deleteCard(deckIndex, phraseId)


	}


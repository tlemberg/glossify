define ->

	############################################################################
	# _stripNumeric
	#
	############################################################################
	_stripNumeric = (s) ->
		s.replace(///[^-\d\.]///g, '')


	############################################################################
	# _shuffle
	#
	############################################################################
	_shuffle: (arr) ->
		i = arr.length;
		if i == 0 then return false

		while --i
			j = Math.floor(Math.random() * (i+1))
			tempi = arr[i]
			tempj = arr[j]
			arr[i] = tempj
			arr[j] = tempi
		return arr


	############################################################################
	# _randomInt
	#
	############################################################################
	_randomInt = (min, max) ->
		Math.floor(Math.random() * max) + min


	############################################################################
	# _logout
	#
	############################################################################
	_logout = ->
		removeLocalStorageItem('user_profile')
		removeLocalStorageItem('dictionary_fr')


	############################################################################
	# _withUnit
	#
	############################################################################
	_withUnit = (measure, unit) ->
		"#{ measure }#{ unit }"


	############################################################################
	# _appWidth
	#
	############################################################################
	_appWidth = ->
		_stripNumeric($(".page").first().css('width'));


	############################################################################
	# _appHeight
	#
	############################################################################
	_appHeight = ->
		_stripNumeric($(".page").first().css('height'));


	############################################################################
	# _windowWidth
	#
	############################################################################
	_windowWidth = ->
		window.innerWidth


	############################################################################
	# _windowHeight
	#
	############################################################################
	_windowHeight = ->
		window.innerHeight


	############################################################################
	# _getUrlParameter
	#
	############################################################################
	_getUrlParameter = (sParam) ->
		sPageURL = window.location.search.substring(1)
		sURLVariables = sPageURL.split('&')
		for i in [0..sURLVariables.length-1]
			sParameterName = sURLVariables[i].split('=');
			if sParameterName[0] == sParam
				raw = sParameterName[1]
				return raw.replace(/\//, '')


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		stripNumeric: (s) ->
			_stripNumeric(s)

		shuffle: (arr) ->
			_shuffle(arr)

		randomInt: (min, max) ->
			_randomInt(min, max)

		logout: ->
			_logout()

		withUnit: (measure, unit) ->
			_withUnit(measure, unit)

		appWidth: ->
			_appWidth()

		appHeight: ->
			_appHeight()

		windowWidth: ->
			_windowWidth()

		windowHeight: ->
			_windowHeight()

		getUrlParameter: (sParam) ->
			_getUrlParameter(sParam)

	}


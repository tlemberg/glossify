define ->

	return {

		stripNumeric: (s) ->
			s.replace(///[^-\d\.]///g, '')


		shuffle: (arr) ->
			i = arr.length;
			if i == 0 then return false

			while --i
				j = Math.floor(Math.random() * (i+1))
				tempi = arr[i]
				tempj = arr[j]
				arr[i] = tempj
				arr[j] = tempi
			return arr


		randomInt: (min, max) ->
			Math.floor(Math.random() * max) + min


		logout: ->
			removeLocalStorageItem('user_profile')
			removeLocalStorageItem('dictionary_fr')


		withUnit: (measure, unit) ->
			"#{ measure }#{ unit }"


		appWidth: ->
			this.stripNumeric($(".page").first().css('width'));


		appHeight: ->
			this.stripNumeric($(".page").first().css('height'));


		windowWidth: ->
			window.innerWidth

		windowHeight: ->
			window.innerHeight

	}


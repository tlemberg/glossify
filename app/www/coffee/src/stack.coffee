define ['utils', 'storage'], (utils, storage) ->

	DICTIONARY_SIZE = 10000

	############################################################################
	# _getBoxes
	#
	############################################################################
	_getBoxes = (plan, documentId) ->

		excerpt_dict = storage.getExcerpts()
		lang = storage.getLanguage()

		boxes = []
		nBoxes = plan.length

		console.log(excerpt_dict)

		for excerptId in plan[documentId]

			excerpt = excerpt_dict[excerptId]
			phraseIds = excerpt['phrase_ids']

			if phraseIds.length > 0

				sample = excerpt['excerpt']

				progressLevels = [1, 2, 3, 4, 5]

				# Is this a character-based language?
				includePron = undefined
				if lang == 'he' or lang == 'zh'
					includePron = 1

				box =
					phraseIds     : phraseIds
					sample        : sample
					excerptId     : excerptId
					progressLevels: progressLevels
					include_pron  : includePron

				boxes.push(box)

		boxes


	############################################################################
	# _getProgressPercentage
	#
	############################################################################
	_getProgressPercentage = (phraseIds, studyMode) ->

		maxProgress = 5 * phraseIds.length

		# Compute the total progress
		totalProgress = 0
		for phraseId in phraseIds
			totalProgress += storage.getProgress(phraseId, studyMode)

		Math.floor(totalProgress / maxProgress * 100)


	############################################################################
	# _updateProgressBars
	#
	############################################################################
	_updateProgressBars = (className, phraseIds) ->
		console.log(className)
		console.log(phraseIds)
		for studyMode in ['defs', 'pron']
			progressHash = {
				1: 0
				2: 0
				3: 0
				4: 0
				5: 0
			}
			totalProgress = 0
			for phraseId in phraseIds
				progress = storage.getProgress(phraseId, studyMode)
				if progress > 0
					progressHash[progress] += 1
					totalProgress += 1
			for progress in Object.keys(progressHash)
				count = progressHash[progress]
				percent = 0
				if count > 0
					percent += count / phraseIds.length * 100
				widthStr = utils.withUnit(percent, '%')
				$(".#{ className } .progress-box-#{ studyMode } .progress-bar-#{ progress }").css('width', widthStr)
				$(".#{ className } .progress-box-#{ studyMode } .progress-counter-#{ progress }").html("#{ count }")


	############################################################################
	# _addExcerpt
	#
	############################################################################
	_addExcerpt = (text) ->
		lang = storage.getLanguage()
		dictionary = storage.getDictionary(lang)
		phraseIds = []
		for phraseSize in [1..4]
			for i in [0..text.length-phraseSize+1]
				j = i + phraseSize
				phrase = text.substring(i, j)
				if phrase of dictionary['bases']
					phraseIds.push(dictionary['bases'][phrase])

		plan = storage.getPlan(lang)
		plan.push
			'excerpt': text
			'phraseIds': phraseIds
		storage.setPlan(lang, plan)


	############################################################################
	# _getExcerpt
	#
	############################################################################
	_getExcerpt = (plan, section, box) ->
		planMode = storage.getPlanMode()

		excerpt = undefined
		if planMode == 'example'
			excerpt = plan[(section - 1) * SECTION_SIZE + box]['excerpt']

		excerpt

			

	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		getSectionInterval: (section) ->
			_getSectionInterval(section)


		getBoxInterval: (section, box) ->
			_getBoxInterval(section, box)


		getPhraseIds: (section, box, lang) ->
			_getPhraseIds(section, box, lang)


		getBoxes: (plan, documentId) ->
			_getBoxes(plan, documentId)


		updateProgressBars: (className, phraseIds) ->
			_updateProgressBars(className, phraseIds)


		addExcerpt: (text) ->
			_addExcerpt(text)


		getExcerpt: (plan, section, box) ->
			_getExcerpt(plan, section, box)


		addPhrasesToDictionary: (d) ->
			lang = storage.getLanguage()
			dictionary = storage.getDictionary(lang)
			for k, v of d
				console.log('adding')
				console.log(k)
				console.log(v)
				dictionary['dictionary'][k] = v
			console.log(Object.keys(dictionary['dictionary']).length)
			storage.setDictionary(lang, dictionary)

	}

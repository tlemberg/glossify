define ['utils', 'storage'], (utils, storage) ->

	SECTION_SIZE    = 1000
	DICTIONARY_SIZE = 10000

	boxSize = 100


	############################################################################
	# _getSectionInterval
	#
	############################################################################
	_getSectionInterval = (section) ->
		minIndex = minIndex = (section - 1) * SECTION_SIZE
		maxIndex = minIndex + SECTION_SIZE - 1

		return {
			min: minIndex
			max: maxIndex
		}


	############################################################################
	# _getSectionInterval
	#
	############################################################################
	_getBoxInterval = (section, box) ->
		minIndex = (section - 1) * SECTION_SIZE + box * boxSize
		maxIndex = minIndex + boxSize

		return {
			min: minIndex
			max: maxIndex
		}


	############################################################################
	# _getPhraseIds
	#
	############################################################################
	_getPhraseIds = (plan, section, boxIndex, lang) ->
		planMode = storage.getPlanMode()

		phraseIds = undefined
		if planMode == 'frequency'

			minIndex = minIndex = (section - 1) * SECTION_SIZE + boxIndex * boxSize
			maxIndex = minIndex + boxSize

			phraseIds = plan.slice(minIndex, maxIndex)

		else

			phraseIds = plan[(section - 1) * SECTION_SIZE + boxIndex]['phraseIds']

		phraseIds


	############################################################################
	# _getBoxes
	#
	############################################################################
	_getBoxes = (plan, dictionary, section, lang, cardsPerBox) ->

		flat = storage.getPlanMode() is 'frequency'


		boxes = []
		nBoxes = undefined
		if flat
			nBoxes = SECTION_SIZE / cardsPerBox
		else
			nBoxes = plan.length

		for boxIndex in [0..nBoxes-1]

			phraseIds = undefined
			if flat?
				phraseIds = _getPhraseIds(plan, section, boxIndex, lang)
			else
				phraseIds = plan[boxIndex]['phraseIds']

			if phraseIds.length > 0

				sample = undefined
				if flat
					samplePhraseIds = phraseIds[0..3]
					sampleWords = (dictionary['dictionary'][phraseId]['base'] for phraseId in samplePhraseIds)
					sample = sampleWords.join(', ') + ", ..."
				else
					sample = plan[boxIndex]['excerpt']

				progressLevels = [1, 2, 3, 4, 5]

				# Is this a character-based language?
				includePron = undefined
				if lang == 'he' or lang == 'zh'
					includePron = 1

				box =
					phraseIds: phraseIds
					minCard: (section - 1) * SECTION_SIZE + boxIndex * cardsPerBox + 1
					maxCard: (section - 1) * SECTION_SIZE + (boxIndex + 1) * cardsPerBox
					sample : sample
					index  : boxIndex
					progressLevels: progressLevels
					include_pron: includePron

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


		getBoxes: (userProfile, dictionary, section, lang, cardsPerBox) ->
			_getBoxes(userProfile, dictionary, section, lang, cardsPerBox)


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

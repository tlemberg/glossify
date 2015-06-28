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
		minIndex = minIndex = (section - 1) * SECTION_SIZE + boxIndex * boxSize
		maxIndex = minIndex + boxSize

		plan.slice(minIndex, maxIndex)


	############################################################################
	# _getBoxes
	#
	############################################################################
	_getBoxes = (plan, dictionary, section, lang, cardsPerBox) ->
		nBoxes = SECTION_SIZE / cardsPerBox

		boxes = []

		for boxIndex in [0..nBoxes-1]
			phraseIds = _getPhraseIds(plan, section, boxIndex, lang)

			if phraseIds.length > 0

				samplePhraseIds = phraseIds[0..3]
				sampleWords = (dictionary['dictionary'][phraseId]['base'] for phraseId in samplePhraseIds)
				sample = sampleWords.join(', ') + "..."

				#percentDefs = _getProgressPercentage(phraseIds, 'defs')
				#percentPron = _getProgressPercentage(phraseIds, 'pron')

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

	}

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

		console.log(minIndex)
		console.log(maxIndex)
		console.log("-----")

		console.log(plan.slice(minIndex, maxIndex))

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
				console.log(Object.keys(dictionary['dictionary']).length)
				console.log(samplePhraseIds)
				sampleWords = (dictionary['dictionary'][phraseId]['base'] for phraseId in samplePhraseIds)
				sample = sampleWords.join(', ') + "..."

				percent = _getProgressPercentage(phraseIds)

				box =
					sample : sample
					index  : boxIndex
					percent: percent

				boxes.push(box)

		boxes


	############################################################################
	# _getProgressPercentage
	#
	############################################################################
	_getProgressPercentage = (phraseIds) ->

		maxProgress = 5 * phraseIds.length

		# Compute the total progress
		totalProgress = 0
		for phraseId in phraseIds
			totalProgress += storage.getProgress(phraseId)

		Math.floor(totalProgress / maxProgress * 100)
			

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

	}

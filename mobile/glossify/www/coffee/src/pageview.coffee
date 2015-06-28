define ['utils', 'constants'], (utils, constants) ->


	############################################################################
	# UI constants
	#
	############################################################################
	MAX_PAGE_WIDTH  = 800
	MAX_PAGE_ASPECT = 1.5


	############################################################################
	# _getHeaderHeight
	#
	############################################################################
	_getHeaderHeight = ->
		utils.appWidth() / 5


	############################################################################
	# _getContentHeight
	#
	############################################################################
	_getContentHeight = ->
		utils.appHeight() - _getHeaderHeight() - _getFooterHeight()


	############################################################################
	# _getFooterHeight
	#
	############################################################################
	_getFooterHeight = ->
		utils.appWidth() / 5


	############################################################################
	# _getAlertHeight
	#
	############################################################################
	_getAlertHeight = ->
		utils.stripNumeric($(".alert-div").css("height"))


	############################################################################
	# _formatPageDimensions
	#
	############################################################################
	_formatPageDimensions = (page, transition = true) ->

		# Compute the page width, height, and position
		pageWidth  = utils.windowWidth()
		#pageHeight = utils.windowHeight()
		marginWidth = (utils.windowWidth() - pageWidth) / 2

		# Set the page width, height, and position using CSS
		$(".page").css('width', utils.withUnit(pageWidth, 'px'))
		#$(".page").css('height', utils.withUnit(pageHeight, 'px'))
		$(".page").css('margin-left', utils.withUnit(marginWidth, 'px'))
		$(".page").css('margin-right', utils.withUnit(marginWidth, 'px'))

		pageIndex = 0
		for i in [0..constants.pages.length]
			if constants.pages[i] == page
				pageIndex = i

		$(".page-container").css('width', utils.withUnit(utils.windowWidth() * constants.pages.length, 'px'))

		if transition
			$(".page-container").animate { "margin-left": utils.withUnit(-1 * pageIndex * utils.windowWidth(), 'px') }, 500, ->
				console.log("done")
		else
			$(".page-container").css("margin-left", utils.withUnit(-1 * pageIndex * utils.windowWidth(), 'px'))


	############################################################################
	# _formatGlobalElements
	#
	############################################################################
	_formatGlobalElements = ->

		# Format the header div
		$('.global-header').css('height', utils.withUnit(_getHeaderHeight(), 'px'))

		# Format the content div
		$('.global-content').css('height', utils.withUnit(_getContentHeight(), 'px'))

		# Format the footer div
		$('.global-footer').css('height', utils.withUnit(_getFooterHeight(), 'px'))


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {


		getHeaderHeight: ->
			_getFooterHeight()


		getFooterHeight: ->
			_getFooterHeight()


		getAlertHeight: ->
			_getAlertHeight()


		formatPageDimensions: (page, transition) ->
			_formatPageDimensions(page, transition)


		formatGlobalElements: ->
			_formatGlobalElements()

	}

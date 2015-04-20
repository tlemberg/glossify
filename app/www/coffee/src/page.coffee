define ['utils'], (utils) ->


	############################################################################
	# UI constants
	#
	############################################################################
	MAX_PAGE_WIDTH  = 400
	MAX_PAGE_ASPECT = 1.5


	############################################################################
	# _getHeaderHeight
	#
	#	Gets the global height of the page footer div, based on the app width
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing
	#
	############################################################################
	_getHeaderHeight = ->
		utils.appWidth() / 5


	############################################################################
	# _getContentHeight
	#
	#	Gets the global height of the page content div, based on the app height
	#	and the heights of the header and footer
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing
	#
	############################################################################
	_getContentHeight = ->
		utils.appHeight() - _getHeaderHeight - _getFooterHeight()


	############################################################################
	# _getFooterHeight
	#
	#	Gets the global height of the page footer div, based on the app width
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing
	#
	############################################################################
	_getFooterHeight = ->
		utils.appWidth() / 5


	############################################################################
	# _formatPageDimensions
	#
	#	Gets the global height of the page footer div, based on the app width
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing
	#
	############################################################################
	_formatPageDimensions = ->

		# Compute the page width, height, and position
		pageWidth  = Math.min(MAX_PAGE_WIDTH, utils.windowWidth())
		pageHeight = Math.min(pageWidth * MAX_PAGE_ASPECT, utils.windowHeight())
		pageX      = (utils.windowWidth() - pageWidth) / 2
		pageY      = (utils.windowHeight() - pageHeight) / 2

		# Set the page width, height, and position using CSS
		$(".page").css('width', utils.withUnit(pageWidth, 'px'))
		$(".page").css('height', utils.withUnit(pageHeight, 'px'))
		$(".page").css('left', utils.withUnit(pageX, 'px'))
		$(".page").css('top', utils.withUnit(pageY, 'px'))


	############################################################################
	# _formatGlobalElements
	#
	#	Formats the elements, such as headers and footers, that are consistent
	#	across pages and based on global CSS properties
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing
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


		formatPageDimensions: ->
			_formatPageDimensions()


		formatGlobalElements: ->
			_formatGlobalElements

	}

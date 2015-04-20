define ['utils', 'nav', 'css'], (utils, nav, css) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_nav = undefined
	_userProfile = undefined
	_dictionary = undefined

	
	############################################################################
	# UI constants
	#
	############################################################################
	PICKER_TILE_MARGIN = 10


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_preloadPage = ->
		console.log('preload')


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_refreshPage = ->
		_setPickerCss()


	############################################################################
	# _preloadPage
	#
	#	Preload the page
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_loadPage = (params) ->

		# Create the picker
		_setPickerHtml()

		# Register page events
		_registerEvents()
		

	############################################################################
	# _setPickerHtml
	#
	#	Set the picker's html
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_setPickerHtml = ->
		# Build the picker UI
		pickerHtml = ''
		for r in [0..99]
			do (r) ->
				pickerHtml += "<div class='overview-row'>"
				for c in [0..3]
					do (c) ->
						tileId = r * 4 + c + 1
						pickerHtml += "<a class='overview-tile-link' data-tile-id='#{ tileId }'>"
						if c is 0
							pickerHtml += "<div class='overview-tile overview-tile-left'>"
						else
							pickerHtml += "<div class='overview-tile'>"
						pickerHtml += "<div class='overview-tile-text'></div>"
						pickerHtml += "</div></a>"
				pickerHtml += "</div>"

		$('#overview-picker').html(pickerHtml)


	############################################################################
	# _setPickerCss
	#
	#	Set the CSS for the picker
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_setPickerCss = ->
		# Get the row width
		rowWidth = utils.appWidth()

		# Define constant margin width
		marginWidth = PICKER_TILE_MARGIN

		# Compute tile width
		tileWidth = (rowWidth - marginWidth * 5) / 4

		# Set the tile width and height to be a square
		$('.overview-tile').css('width', tileWidth + "px");
		$('.overview-tile').css('height', tileWidth + "px");

		# Set the margins
		$('.overview-tile').css('margin-right', marginWidth);
		$('.overview-tile-left').css('margin-left', marginWidth);
		$('.overview-tile').css('margin-top', marginWidth);


	############################################################################
	# _registerEvents
	#
	#	Register page events
	#
	# Parameters:
	#	None
	#	
	# Returns:
	#	Nothing.
	#
	############################################################################
	_registerEvents = ->

		# Clicking on a tile on the overview page
		$('.overview-tile-link').click (event) ->
			event.preventDefault();
			tileId = $(this).data("tile-id")

			_nav.loadPage 'study',
				userProfile: _userProfile
				dictionary : _dictionary
				tileId     : tileId


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		preloadPage: ->
			_nav = require('nav')
			_preloadPage()


		refreshPage: ->
			_refreshPage()


		loadPage: (params) ->
			_loadPage(params)


	}

define ['require', 'api', 'css', 'page', 'login', 'signup', 'manage', 'overview', 'study', 'utils'], (require, api, css, page, login, signup, manage, overview, study, utils) ->

	currentPageId = 'overview'
	currentParams = {}

	_token       = undefined
	_userProfile = undefined
	_dictionary  = undefined


	return {

		pageRenderers: ->
			login:
				preload: require('login').preloadPage 
				load   : require('login').loadPage 
				refresh: require('login').refreshPage
			signup:
				preload: require('signup').preloadPage 
				load   : require('signup').loadPage 
				refresh: require('signup').refreshPage
			manage:
				preload: require('manage').preloadPage 
				load   : require('manage').loadPage 
				refresh: require('manage').refreshPage
			overview:
				preload: require('overview').preloadPage 
				load   : require('overview').loadPage 
				refresh: require('overview').refreshPage 
			study:
				preload: require('study').preloadPage 
				load   : require('study').loadPage 
				refresh: require('study').refreshPage 


		# Preload pages
		preloadPages: (initialPageId, params) ->
			# Make all pages invisible
			$(".page").hide()

			pageRenderers = this.pageRenderers()
			mod = this
			
			# Then preload all pages
			for pageId, actions of pageRenderers
				actions['preload']()

			css.refreshStaticCss()

			# Load an initial page
			this.loadPage(initialPageId, params)


		# Load pages
		loadPage: (pageId, params) ->

			pageRenderers = this.pageRenderers()

			currentPageId = pageId

			# Render the page, creating if necessary
			pageRenderers[pageId]['load'](params)
			
			this.refreshPage()

			# Refresh static CSS
			css.refreshStaticCss()

			# Make the page visible
			$("##{ pageId }-page").css('visibility', 'visible')

			# Show the page now that it has been rendered
			$(".page").hide()
			$(".splash").hide()
			$("##{ pageId }-page").show()


		# Refresh page
		refreshPage: ->
			# Width and height
			page.formatPageDimensions()

			# Global elements
			page.formatGlobalElements()

			this.pageRenderers()[currentPageId]['refresh']()

	}

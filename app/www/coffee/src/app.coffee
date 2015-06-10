requirejs.config
	baseUrl: 'coffee/lib',
	paths:
		jquery: '../../js/jquery-2.1.3.min'
		hbs: '../../require-handlebars-plugin/hbs'
		

requirejs [
	'jquery',
	'nav',
	'storage',
], ($, nav, storage, url) ->


	############################################################################
	# ready
	#
	############################################################################
	$(document).ready (event) ->
		storage.logout()
		nav.initPages()

		if storage.isLoggedIn()
			nav.loadPage('overview')
		else
			nav.loadPage('login')
		

	############################################################################
	# resize
	#
	############################################################################
	$(window).resize (event) ->
		nav.refreshPage()
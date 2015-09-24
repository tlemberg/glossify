requirejs.config
	baseUrl: 'coffee/lib',
	paths:
		jquery: '../../js/jquery-2.1.3.min'
		hbs: '../../require-handlebars-plugin/hbs'
		

requirejs [
	'jquery',
	'nav',
	'storage',
	'api',
], ($, nav, storage, url, api) ->


	############################################################################
	# ready
	#
	############################################################################
	$(document).ready (event) ->
		nav.initPages()

		api = require('api')

		( ->
			if storage.isLoggedIn() and navigator.onLine
				progressUpdates = storage.getProgressUpdates()
				console.log(progressUpdates)
				if progressUpdates? and not storage.progressUpdatesEmpty()
					api.updateProgress (json) ->
						console.log('update progress')
			console.log('timer progress')
			setTimeout(arguments.callee, 30000)
		)();

		if storage.isLoggedIn()
			nav.loadPage('manage')
		else
			nav.loadPage('login')
		

	############################################################################
	# resize
	#
	############################################################################
	$(window).resize (event) ->
		nav.refreshPage()
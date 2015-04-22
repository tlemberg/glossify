requirejs.config
	baseUrl: 'coffee/lib',
	paths:
		jquery: '../../js/jquery-2.1.3.min'

requirejs ['jquery', 'storage', 'strings', 'utils', 'deck', 'api', 'nav', 'css', 'login', 'signup', 'manage', 'overview', 'study'], ($, storage, strings, utils, deck, api, nav, css, login, signup, manage, overview, study) ->

	$(document).ready (event) ->
		#logout()

		#createUser 'clemberg10@gmail.com', 'gpass', (r) ->
		#	console.log(r)

		#fetchAccessToken 'clemberg10@gmail.com', 'gpass', (token) ->
		#	addLanguage 'clemberg10@gmail.com', 'fr', token, (r) ->
		#		console.log(r)

		userProfile = storage.getUserProfile()
		if userProfile?
			nav.preloadPages('overview')
		else
			nav.preloadPages('login')


	$(window).resize (event) ->
		nav.refreshPage()
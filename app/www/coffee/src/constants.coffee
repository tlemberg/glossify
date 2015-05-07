define [
	'jquery',
	'hbs!../../hbs/src/login',
	'hbs!../../hbs/src/signup',
	'hbs!../../hbs/src/overview',	
	'hbs!../../hbs/src/study',
	'login',
	'signup',
	'overview',
	'study',
],
(
	$,
	loginTemplate,
	signupTemplate,
	overviewTemplate,
	studyTemplate,
	login,
	signup,
	overview,
	study,
) ->


	############################################################################
	# Module properties
	#
	############################################################################
	_pageActionMap =
		login:
			load   : login.loadPage
			refresh: login.refreshPage
		signup:
			load   : signup.loadPage
			refresh: signup.refreshPage
		overview:
			load   : overview.loadPage
			refresh: overview.refreshPage
		study:
			load   : study.loadPage
			refresh: study.refreshPage

	_templateMap =
		login    : loginTemplate
		signup   : signupTemplate
		overview : overviewTemplate
		study    : studyTemplate
		
	_pages = [
		'login',
		'signup',
		'overview',
		'study',
	]


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		pageActionMap: _pageActionMap

		templateMap: _templateMap

		pages: _pages

	}


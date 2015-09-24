define [
	'jquery',
	'hbs!../../hbs/src/login',
	'hbs!../../hbs/src/signup',
	'hbs!../../hbs/src/manage',
	'hbs!../../hbs/src/library',
	'hbs!../../hbs/src/overview',
	'hbs!../../hbs/src/study',
	'login',
	'signup',
	'manage',
	'library',
	'overview',
	'study',
],
(
	$,
	loginTemplate,
	signupTemplate,
	manageTemplate,
	libraryTemplate,
	overviewTemplate,
	studyTemplate,
	login,
	signup,
	manage,
	library,
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
		manage:
			load   : manage.loadPage
			refresh: manage.refreshPage
		library:
			load   : library.loadPage
			refresh: library.refreshPage
		overview:
			load   : overview.loadPage
			refresh: overview.refreshPage
		study:
			load   : study.loadPage
			refresh: study.refreshPage

	_templateMap =
		login    : loginTemplate
		signup   : signupTemplate
		manage   : manageTemplate
		library  : libraryTemplate
		overview : overviewTemplate
		study    : studyTemplate
		
	_pages = [
		'login',
		'signup',
		'manage',
		'library',
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

		langMap:
			'aa': 'Afar'
			'ab': 'Abkhaz'
			'ae': 'Avestan'
			'af': 'Afrikaans'
			'ak': 'Akan'
			'am': 'Amharic'
			'an': 'Aragonese'
			'ar': 'Arabic'
			'as': 'Assamese'
			'av': 'Avaric'
			'ay': 'Aymara'
			'az': 'Azerbaijani'
			'ba': 'Bashkir'
			'be': 'Belarusian'
			'bg': 'Bulgarian'
			'bh': 'Bihari'
			'bi': 'Bislama'
			'bm': 'Bambara'
			'bn': 'Bengali'
			'bo': 'Tibetan'
			'br': 'Breton'
			'bs': 'Bosnian'
			'ca': 'Catalan'
			'ce': 'Chechen'
			'ch': 'Chamorro'
			'co': 'Corsican'
			'cr': 'Cree'
			'cs': 'Czech'
			'cu': 'Old Church Slavonic'
			'cv': 'Chuvash'
			'cy': 'Welsh'
			'da': 'Danish'
			'de': 'German'
			'dv': 'Dhivehi'
			'ee': 'Ewe'
			'el': 'Greek'
			'en': 'English'
			'eo': 'Esperanto'
			'es': 'Spanish'
			'et': 'Estonian'
			'eu': 'Basque'
			'fa': 'Persian'
			'ff': 'Fula'
			'fi': 'Finnish'
			'fj': 'Fijian'
			'fo': 'Faroese'
			'fr': 'French'
			'fy': 'West Frisian'
			'ga': 'Irish'
			'gd': 'Scottish Gaelic'
			'gl': 'Galician'
			'gn': 'Guaraní'
			'gu': 'Gujarati'
			'gv': 'Manx'
			'ha': 'Hausa'
			'he': 'Hebrew'
			'hi': 'Hindi'
			'ho': 'Hiri Motu'
			'hr': 'Croatian'
			'ht': 'Haitian Creole'
			'hu': 'Hungarian'
			'hy': 'Armenian'
			'hz': 'Herero'
			'ia': 'Interlingua'
			'id': 'Indonesian'
			'ie': 'Interlingue'
			'ig': 'Igbo'
			'ii': 'Nuosu'
			'ik': 'Inupiaq'
			'io': 'Ido'
			'is': 'Icelandic'
			'it': 'Italian'
			'iu': 'Inuktitut'
			'ja': 'Japanese'
			'jv': 'Javanese'
			'ka': 'Georgian'
			'kg': 'Kongo'
			'ki': 'Kikuyu'
			'kj': 'Kwanyama'
			'kk': 'Kazakh'
			'kl': 'Greenlandic'
			'km': 'Khmer'
			'kn': 'Kannada'
			'ko': 'Korean'
			'kr': 'Kanuri'
			'ks': 'Kashmiri'
			'ku': 'Kurdish'
			'kv': 'Komi'
			'kw': 'Cornish'
			'ky': 'Kyrgyz'
			'la': 'Latin'
			'lb': 'Luxembourgish'
			'lg': 'Luganda'
			'li': 'Limburgish'
			'ln': 'Lingala'
			'lo': 'Lao'
			'lt': 'Lithuanian'
			'lu': 'Luba-Katanga'
			'lv': 'Latvian'
			'mg': 'Malagasy'
			'mh': 'Marshallese'
			'mi': 'Māori'
			'mk': 'Macedonian'
			'ml': 'Malayalam'
			'mn': 'Mongolian'
			'mr': 'Marathi'
			'ms': 'Malay'
			'mt': 'Maltese'
			'my': 'Burmese'
			'na': 'Nauru'
			'nb': 'Norwegian Bokmål'
			'nd': 'North Ndebele'
			'ne': 'Nepali'
			'ng': 'Ndonga'
			'nl': 'Dutch'
			'nn': 'Norwegian Nynorsk'
			'no': 'Norwegian'
			'nr': 'South Ndebele'
			'nv': 'Navajo'
			'ny': 'Chichewa'
			'oc': 'Occitan'
			'oj': 'Ojibwe'
			'om': 'Oromo'
			'or': 'Oriya'
			'os': 'Ossetian'
			'pa': 'Punjabi'
			'pi': 'Pali'
			'pl': 'Polish'
			'ps': 'Pashto'
			'pt': 'Portuguese'
			'qu': 'Quechua'
			'rm': 'Romansh'
			'rn': 'Kirundi'
			'ro': 'Romanian'
			'ru': 'Russian'
			'rw': 'Kinyarwanda'
			'sa': 'Sanskrit'
			'sc': 'Sardinian'
			'sd': 'Sindhi'
			'se': 'Northern Sami'
			'sg': 'Sango'
			'si': 'Sinhalese'
			'sk': 'Slovak'
			'sl': 'Slovene'
			'sm': 'Samoan'
			'sn': 'Shona'
			'so': 'Somali'
			'sq': 'Albanian'
			'sr': 'Serbian'
			'ss': 'Swati'
			'st': 'Southo'
			'su': 'Sundanese'
			'sv': 'Swedish'
			'sw': 'Swahili'
			'ta': 'Tamil'
			'te': 'Telugu'
			'tg': 'Tajik'
			'th': 'Thai'
			'ti': 'Tigrinya'
			'tk': 'Turkmen'
			'tl': 'Tagalog'
			'tn': 'Tswana'
			'to': 'Tonga'
			'tr': 'Turkish'
			'ts': 'Tsonga'
			'tt': 'Tatar'
			'tw': 'Twi'
			'ty': 'Tahitian'
			'ug': 'Uyghur'
			'uk': 'Ukrainian'
			'ur': 'Urdu'
			'uz': 'Uzbek'
			've': 'Venda'
			'vi': 'Vietnamese'
			'vo': 'Volapük'
			'wa': 'Walloon'
			'wo': 'Wolof'
			'xh': 'Xhosa'
			'yi': 'Yiddish'
			'yo': 'Yoruba'
			'za': 'Zhuang'
			'zh': 'Chinese'

	}


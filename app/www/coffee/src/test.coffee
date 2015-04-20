requirejs.config
	baseUrl: 'coffee/lib',
	paths:
		jquery: '../../js/jquery-2.1.3.min'

requirejs ['jquery', 'utils', 'deck', 'api', 'overview', 'study', 'nav'], ($, utils, deck, api, overview, study, nav) ->

	### Deck tests ###

	QUnit.test "hello test", (assert) ->
		assert.ok(1 == "1", "Passed!")

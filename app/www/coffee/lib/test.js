// Generated by CoffeeScript 1.9.1
(function() {
  requirejs.config({
    baseUrl: 'coffee/lib',
    paths: {
      jquery: '../../js/jquery-2.1.3.min'
    }
  });

  requirejs(['jquery', 'utils', 'deck', 'api', 'overview', 'study', 'nav'], function($, utils, deck, api, overview, study, nav) {

    /* Deck tests */
    return QUnit.test("hello test", function(assert) {
      return assert.ok(1 === "1", "Passed!");
    });
  });

}).call(this);
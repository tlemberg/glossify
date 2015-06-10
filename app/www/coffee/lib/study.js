// Generated by CoffeeScript 1.9.2
(function() {
  define(['utils', 'stack', 'storage', 'nav', 'deck', 'pageview', 'api'], function(utils, stack, storage, nav, deck, pageview, api) {
    var CARD_ASPECT, MAX_BUTTON_AREA_WIDTH, MAX_CARD_WIDTH, _deck, _getTxSummary, _hideFlipButton, _isFlipped, _loadPage, _nav, _phrase, _refreshPage, _registerEvents, _resetCard, _setBottomText, _setStudyFooterCss, _setStudyFooterHtml, _setTopText, _showFlipButton;
    _nav = void 0;
    _isFlipped = false;
    _phrase = void 0;
    _deck = void 0;
    MAX_CARD_WIDTH = 340;
    MAX_BUTTON_AREA_WIDTH = 600;
    CARD_ASPECT = 1.5;
    _loadPage = function(template) {
      var box, dictionary, lang, phraseIds, plan, section, templateArgs, userProfile;
      userProfile = storage.getUserProfile();
      lang = storage.getLanguage();
      section = storage.getSection();
      box = storage.getBox();
      plan = storage.getPlan(lang);
      dictionary = storage.getDictionary(lang);
      phraseIds = stack.getPhraseIds(plan, section, box, lang);
      _deck = deck.createDeck(phraseIds, dictionary);
      _phrase = deck.drawPhrase(_deck);
      _isFlipped = false;
      templateArgs = {
        buttons: [
          {
            progress: 1,
            text: "don't know"
          }, {
            progress: 2,
            text: ""
          }, {
            progress: 3,
            text: ""
          }, {
            progress: 4,
            text: ""
          }, {
            progress: 5,
            text: "know"
          }
        ]
      };
      $(".study-page").html(template(templateArgs));
      _setStudyFooterCss();
      _resetCard();
      _nav.showBackBtn("Done", function(event) {
        var progressUpdates;
        progressUpdates = storage.getProgressUpdates();
        if ((progressUpdates != null) && progressUpdates !== {}) {
          return api.updateProgress(function(json) {
            return _nav.loadPage('overview');
          });
        } else {
          return _nav.loadPage('overview');
        }
      });
      return _registerEvents();
    };
    _registerEvents = function() {
      $('.study-page .flip-btn').click(function(event) {
        _isFlipped = true;
        return _resetCard();
      });
      return $('.study-page .btn').click(function(event) {
        storage.setProgress(_phrase['_id'], $(this).data('progress'));
        deck.refreshDeck(_deck);
        _phrase = deck.drawPhrase(_deck);
        _isFlipped = false;
        return _resetCard();
      });
    };
    _resetCard = function() {
      var i, j, progressValue, txSummary;
      _setTopText(_phrase['base']);
      progressValue = storage.getProgress(_phrase['_id']);
      for (i = j = 0; j <= 5; i = ++j) {
        $('.study-page .card').removeClass("card-progress-" + i);
      }
      $('.study-page .card').addClass("card-progress-" + progressValue);
      if (!_isFlipped) {
        return _showFlipButton();
      } else {
        txSummary = _getTxSummary(_phrase['txs']);
        _setBottomText(txSummary);
        return _hideFlipButton();
      }
    };
    _setTopText = function(text) {
      return $('.study-page .card-top-text').html(text);
    };
    _setBottomText = function(text) {
      return $('.study-page .card-bottom-text').html(text);
    };
    _refreshPage = function() {
      return _setStudyFooterCss();
    };
    _showFlipButton = function() {
      $('.study-page .flip-btn').show();
      $('.study-page .card-bottom-text').hide();
      return $('.study-page .btn-container').hide();
    };
    _hideFlipButton = function() {
      $('.study-page .flip-btn').hide();
      $('.study-page .card-bottom-text').show();
      return $('.study-page .btn-container').show();
    };
    _getTxSummary = function(txs) {
      var i, k, lines, s, v;
      s = '';
      for (k in txs) {
        v = txs[k];
        lines = (function() {
          var j, ref, results;
          results = [];
          for (i = j = 0, ref = Math.min(v.length - 1, 2); 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
            results.push((i + 1) + ". " + v[i]);
          }
          return results;
        })();
        s = s + ("<div><b>" + k + "</b>") + "<br />" + lines.join("<br />") + "</div>";
        break;
      }
      return s;
    };
    _setStudyFooterHtml = function() {
      var c, footerHtml, j, results;
      footerHtml = ((function() {
        var j, results;
        results = [];
        for (c = j = 1; j <= 5; c = ++j) {
          results.push("<div id='study-btn-" + c + "' class='study-btn' data-progress=" + c + ">\n	<div class='study-btn-text'>" + c + "</div>\n</div>");
        }
        return results;
      })()).join("\n");
      $('#study-btn-container').html(footerHtml);
      results = [];
      for (c = j = 1; j <= 5; c = ++j) {
        results.push((function(c) {
          return $("#study-btn-" + c).css('background-color', BG_COLORS[c]);
        })(c));
      }
      return results;
    };
    _setStudyFooterCss = function() {
      var btnWidth, cardHeight, cardWidth;
      cardHeight = utils.windowHeight() - 200;
      cardWidth = Math.min(MAX_CARD_WIDTH, cardHeight / CARD_ASPECT);
      $('.study-page .card-container').css('width', cardWidth);
      $('.study-page .card').css('height', cardHeight);
      btnWidth = (cardWidth - 20) / 5;
      $('.study-page .btn').css('width', btnWidth);
      $('.study-page .btn').css('height', btnWidth);
      $('.study-page .btn').css('margin-top', '5px');
      $('.study-page .btn').css('margin-right', '5px');
      $('.study-page .btn-5').css('margin-right', '0px');
      return $('.study-page .flip-btn').css('height', btnWidth);
    };
    return {
      loadPage: function(template) {
        _nav = require('nav');
        return _loadPage(template);
      },
      refreshPage: function() {
        return _refreshPage();
      }
    };
  });

}).call(this);

// Generated by CoffeeScript 1.9.1
(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['utils', 'storage'], function(utils, storage) {
    var MAX_BUFFER, _createDeck, _drawPhrase, _refreshDeck;
    MAX_BUFFER = 3;
    _createDeck = function(phraseIds) {
      var deck, dictionary, j, lang, len, phraseId, phraseList, phraseMap;
      lang = storage.getLanguage();
      dictionary = storage.getDictionary(lang);
      phraseList = (function() {
        var j, len, results;
        results = [];
        for (j = 0, len = phraseIds.length; j < len; j++) {
          phraseId = phraseIds[j];
          results.push(dictionary['dictionary'][phraseId]);
        }
        return results;
      })();
      phraseMap = {};
      for (j = 0, len = phraseIds.length; j < len; j++) {
        phraseId = phraseIds[j];
        phraseMap[phraseId] = dictionary[phraseId];
      }
      deck = {
        lang: dictionary['lang'],
        phraseList: phraseList,
        phraseMap: phraseMap,
        buffer: []
      };
      _refreshDeck(deck);
      return deck;
    };
    _refreshDeck = function(deck) {
      var a, fn, i, j, k, lang, len, maxPenalty, p, penalty, phrase, pool, poolPhrases, ref, totalPenalty;
      lang = storage.getLanguage();
      totalPenalty = 0;
      maxPenalty = deck['phraseList'].length;
      poolPhrases = [];
      i = 0;
      while (totalPenalty < maxPenalty) {
        console.log(totalPenalty);
        console.log(maxPenalty);
        phrase = deck['phraseList'][i];
        penalty = 6 - storage.getProgress(phrase['_id']);
        totalPenalty += penalty;
        if (totalPenalty > maxPenalty) {
          break;
        }
        poolPhrases.push(phrase);
        i += 1;
      }
      console.log("POOL");
      console.log(poolPhrases);
      p = 0;
      pool = {};
      for (j = 0, len = poolPhrases.length; j < len; j++) {
        phrase = poolPhrases[j];
        penalty = 6 - storage.getProgress(phrase['_id']);
        fn = function(a) {
          p += 1;
          return pool[p] = phrase;
        };
        for (a = k = 0, ref = penalty - 1; 0 <= ref ? k <= ref : k >= ref; a = 0 <= ref ? ++k : --k) {
          fn(a);
        }
      }
      deck['pool'] = pool;
      return deck['poolSize'] = Object.keys(pool).length;
    };
    _drawPhrase = function(deck) {
      var p, phrase;
      console.log(deck);
      while ((phrase == null) || indexOf.call(deck['buffer'], phrase) >= 0) {
        p = utils.randomInt(0, deck['poolSize'] - 1);
        phrase = deck['pool'][p];
      }
      deck['buffer'].push(phrase);
      if (deck['buffer'].length > MAX_BUFFER) {
        deck['buffer'].shift();
      }
      return phrase;
    };
    return {
      createDeck: function(phraseIds) {
        return _createDeck(phraseIds);
      },
      refreshDeck: function(deck) {
        return _refreshDeck(deck);
      },
      drawPhrase: function(deck) {
        return _drawPhrase(deck);
      }
    };
  });

}).call(this);

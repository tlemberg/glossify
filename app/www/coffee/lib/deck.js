// Generated by CoffeeScript 1.9.1
(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['utils', 'storage'], function(utils, storage) {
    var BOX_SIZE, DICTIONARY_SIZE, MAX_BUFFER, PAGE_SIZE, refreshPool;
    MAX_BUFFER = 3;
    BOX_SIZE = 100;
    PAGE_SIZE = 1000;
    DICTIONARY_SIZE = 10000;
    refreshPool = function(deck) {
      var a, card, fn, i, j, k, len, maxPenalty, p, penalty, pool, poolCards, ref, totalPenalty;
      totalPenalty = 0;
      maxPenalty = deck.cards.length;
      poolCards = [];
      i = 0;
      while (totalPenalty < maxPenalty) {
        card = deck['cards'][i];
        penalty = 6 - card['progress'];
        totalPenalty += penalty;
        if (totalPenalty > maxPenalty) {
          break;
        }
        poolCards.push(card);
        i += 1;
      }
      p = 0;
      pool = {};
      for (j = 0, len = poolCards.length; j < len; j++) {
        card = poolCards[j];
        penalty = 6 - card['progress'];
        fn = function(a) {
          p += 1;
          return pool[p] = card;
        };
        for (a = k = 0, ref = penalty - 1; 0 <= ref ? k <= ref : k >= ref; a = 0 <= ref ? ++k : --k) {
          fn(a);
        }
      }
      deck['pool'] = pool;
      return deck['poolSize'] = Object.keys(pool).length;
    };
    return {
      createDeck: function(cards, dictionary) {
        var card, cardList, cardMap, deck, j, len;
        cardList = (function() {
          var j, len, results;
          results = [];
          for (j = 0, len = cards.length; j < len; j++) {
            card = cards[j];
            results.push({
              phrase_id: card['phrase_id'],
              phrase: dictionary['dictionary'][card['phrase_id']],
              progress: card['progress']
            });
          }
          return results;
        })();
        cardMap = {};
        for (j = 0, len = cardList.length; j < len; j++) {
          card = cardList[j];
          cardMap[card['phrase_id']] = card;
        }
        deck = {
          lang: dictionary['lang'],
          cards: cardList,
          cardMap: cardMap,
          buffer: []
        };
        refreshPool(deck);
        return deck;
      },
      drawCard: function(deck) {
        var card, p;
        while ((card == null) || indexOf.call(deck['buffer'], card) >= 0) {
          p = utils.randomInt(0, deck['poolSize'] - 1);
          card = deck['pool'][p];
        }
        deck['buffer'].push(card);
        if (deck['buffer'].length > MAX_BUFFER) {
          deck['buffer'].shift();
        }
        return card;
      },
      updateCard: function(deck, card) {
        deck['cards'][card['phrase_id']] = card;
        return refreshPool(deck);
      },
      boxSize: function() {
        return BOX_SIZE;
      },
      pageSize: function() {
        return PAGE_SIZE;
      },
      dictionarySize: function() {
        return DICTIONARY_SIZE;
      }
    };
  });

}).call(this);
// Generated by CoffeeScript 1.9.2
(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['utils', 'storage', 'api', 'nav', 'css', 'deck', 'stack', 'strings', 'hbs!../../hbs/src/box-list'], function(utils, storage, api, nav, css, deck, stack, strings, boxListTemplate) {
    var PICKER_TILE_MARGIN, _createEmptyProgress, _loadBoxList, _loadPage, _nPages, _nav, _refreshPage, _registerEvents, _reloadPlan;
    _nav = void 0;
    _nPages = 10;
    PICKER_TILE_MARGIN = 10;
    _loadPage = function(template) {
      var dictionary, doc, documentId, documents, lang, plan, planLength, templateArgs, userProfile;
      lang = storage.getLanguage();
      userProfile = storage.getUserProfile();
      if (indexOf.call(Object.keys(userProfile['langs']), lang) < 0) {
        _createEmptyProgress();
      }
      userProfile = storage.getUserProfile();
      dictionary = storage.getDictionary(lang);
      plan = storage.getPlan(lang);
      planLength = plan.length;
      _nPages = Math.ceil(planLength / 1000);
      documents = storage.getDocuments();
      documentId = storage.getDocumentId();
      doc = documents[documentId];
      templateArgs = {
        documentTitle: doc['title']
      };
      $(".overview-page").html(template(templateArgs));
      _loadBoxList(false);
      _nav.showBackBtn("Library", function(event) {
        return _nav.loadPage('library');
      });
      if (!userProfile['confirmed']) {
        _nav.showAlert("You will need to check your email to confirm your email address and fully activate yout account.");
      }
      return _registerEvents();
    };
    _refreshPage = function() {
      return _loadBoxList(false);
    };
    _loadBoxList = function(transition) {
      var boxes, dictionary, documentId, excerptId, excerpts, i, lang, len, matchWidth, plan, ref, templateArgs, userProfile;
      if (transition == null) {
        transition = true;
      }
      userProfile = storage.getUserProfile();
      lang = storage.getLanguage();
      dictionary = storage.getDictionary(lang);
      plan = storage.getPlan(lang);
      documentId = storage.getDocumentId();
      boxes = stack.getBoxes(plan, documentId);
      templateArgs = {
        boxes: boxes
      };
      $(".overview-page .box-list").html(boxListTemplate(templateArgs));
      excerpts = storage.getExcerpts();
      ref = plan[documentId];
      for (i = 0, len = ref.length; i < len; i++) {
        excerptId = ref[i];
        stack.updateProgressBars("box-div-" + excerptId, excerpts[excerptId]['phrase_ids']);
      }
      $(".overview-page .box-list").css("width", utils.withUnit(utils.windowWidth(), 'px'));
      $(".overview-page .box-list-container").css("width", utils.withUnit(utils.windowWidth() * 10, 'px'));
      matchWidth = $(".overview-page .box-list").css("width");
      $(".overview-page .box-list").css("width", matchWidth);
      $(".box-list-container .box-div").off('click');
      return $(".box-list .box-div").click(function(event) {
        storage.setExcerptId($(this).data('excerpt-id'));
        return _nav.loadPage('study');
      });
    };
    _registerEvents = function() {
      return console.log('events');
    };
    _reloadPlan = function() {
      var lang, plan_mode;
      plan_mode = storage.getPlanMode();
      lang = storage.getLanguage();
      return api.ensurePlan(function(json) {
        if (json['success']) {
          return api.ensureExcerptDictionary(lang, function(json) {
            console.log(json);
            if (json['success']) {
              if (plan_mode === 'example') {
                $('.overview-page .add-example-div').show();
              } else {
                $('.overview-page .add-example-div').hide();
              }
              return _loadBoxList();
            } else {
              return $('.login-page .error').html(strings.getString('unexpectedFailure'));
            }
          });
        } else {
          return $('.login-page .error').html(strings.getString('unexpectedFailure'));
        }
      });
    };
    _createEmptyProgress = function() {
      var dictionary, i, lang, len, phraseId, phrases, ref, userProfile;
      lang = storage.getLanguage();
      dictionary = storage.getDictionary(lang);
      userProfile = storage.getUserProfile();
      phrases = [];
      ref = Object.keys(dictionary['dictionary']);
      for (i = 0, len = ref.length; i < len; i++) {
        phraseId = ref[i];
        phrases.push({
          phrase_id: phraseId,
          progress: 0
        });
      }
      userProfile['langs'][lang] = phrases;
      return storage.setUserProfile(userProfile);
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

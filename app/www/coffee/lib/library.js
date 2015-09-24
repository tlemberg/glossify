// Generated by CoffeeScript 1.9.2
(function() {
  define(['storage', 'api', 'strings'], function(storage, api, strings) {
    var _loadPage, _nav, _refreshPage, _template, _validLangs;
    _nav = void 0;
    _validLangs = ['cy', 'de', 'eo', 'es', 'fr', 'he', 'ru', 'zh'];
    _template = void 0;
    _loadPage = function(template) {
      var constants, docs, planMode, ref, templateArgs, userProfile;
      _template = template;
      userProfile = storage.getUserProfile();
      constants = require('constants');
      planMode = (ref = storage.getPlanMode()) != null ? ref : 'example';
      storage.setPlanMode(planMode);
      docs = storage.getDocuments();
      templateArgs = {
        docs: docs
      };
      console.log(template);
      $(".library-page").html(template(templateArgs));
      $('.library-page .box').click(function(event) {
        var documentId;
        documentId = $(this).data('document-id');
        storage.setDocumentId(documentId);
        return _nav.loadPage('overview');
      });
      _nav.showBackBtn("Logout", function(event) {
        storage.logout();
        return _nav.loadPage('login');
      });
      return $('.library-page .add-doc-btn').click(function(event) {
        var text, title;
        title = $('.library-page .add-doc-title-input').val();
        text = $('.library-page .add-doc-text-input').val();
        console.log(text);
        return api.addDocument(title, text, function(json) {
          if (json['success']) {
            storage.setDocumentId(json['result']);
            return api.getPlan(function(json) {
              var lang;
              if (json['success']) {
                lang = storage.getLanguage();
                return api.ensureExcerptDictionary(lang, function(json) {
                  if (json['success']) {
                    return _nav.loadPage('overview');
                  } else {
                    return $('.login-page .error').html(strings.getString('unexpectedFailure'));
                  }
                });
              } else {
                return $('.login-page .error').html(strings.getString('unexpectedFailure'));
              }
            });
          } else {
            return $('.login-page .error').html(strings.getString('unexpectedFailure'));
          }
        });
      });
    };
    _refreshPage = function() {
      return console.log("refresh");
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
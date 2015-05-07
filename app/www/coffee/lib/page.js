// Generated by CoffeeScript 1.9.1
(function() {
  define(['utils'], function(utils) {
    var MAX_PAGE_ASPECT, MAX_PAGE_WIDTH, _formatGlobalElements, _formatPageDimensions, _getContentHeight, _getFooterHeight, _getHeaderHeight;
    MAX_PAGE_WIDTH = 800;
    MAX_PAGE_ASPECT = 1.5;
    _getHeaderHeight = function() {
      return utils.appWidth() / 5;
    };
    _getContentHeight = function() {
      return utils.appHeight() - _getHeaderHeight() - _getFooterHeight();
    };
    _getFooterHeight = function() {
      return utils.appWidth() / 5;
    };
    _formatPageDimensions = function() {
      var pageHeight, pageWidth;
      pageWidth = Math.min(MAX_PAGE_WIDTH, utils.windowWidth());
      pageHeight = utils.windowHeight();
      $(".page").css('width', utils.withUnit(pageWidth, 'px'));
      $(".page").css('height', utils.withUnit(pageHeight, 'px'));
      $(".page").css('margin-left', 'auto');
      return $(".page").css('margin-right', 'auto');
    };
    _formatGlobalElements = function() {
      $('.global-header').css('height', utils.withUnit(_getHeaderHeight(), 'px'));
      $('.global-content').css('height', utils.withUnit(_getContentHeight(), 'px'));
      return $('.global-footer').css('height', utils.withUnit(_getFooterHeight(), 'px'));
    };
    return {
      getHeaderHeight: function() {
        return _getFooterHeight();
      },
      getFooterHeight: function() {
        return _getFooterHeight();
      },
      formatPageDimensions: function() {
        return _formatPageDimensions();
      },
      formatGlobalElements: function() {
        return _formatGlobalElements();
      }
    };
  });

}).call(this);

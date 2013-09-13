// require jquery
// require ui.alert

(function($, App) {
  App.error = {
    parseError: function(error, defaultMsg) {
      var _error;
      try { // 尝试转换为 json 格式
        _error = App.error.Error( $.parseJSON(error) );
      } catch (ee) { // 转换失败
        _error = App.error.Error(defaultMsg);
      }
      return _error;
    },

    XHRError: function(jqXHR, httpStatus, throwErrors, defaultMsg) {
      return App.error.parseError(jqXHR.responseText, defaultMsg);
    },

    handleXHRError: function(jqXHR, httpStatus, throwErrors, defaultMsg) {
      var errorMsg = App.error.XHRError(jqXHR, httpStatus, throwErrors, defaultMsg);
      $.alert(errorMsg, httpStatus, 2);
    },
    
    XHRErrorHandler: function(defaultMsg) {
      return function(jqXHR, httpStatus, throwErrors) {
        App.error.handleXHRError(jqXHR, httpStatus, throwErrors, defaultMsg);
      };
    }
  };

  App.error.Error = function(error) {
    if (!$.isPlainObject(error)) {
      error = {
        message: (error && error.toString()),
        code: 500
      };
    }
    error.message = error.message || "发生未知错误！";
    error.code = error.code || 0;
    error.toString = function() {
      return this.message;
    }
    return error;
  };
})(jQuery, window.App);

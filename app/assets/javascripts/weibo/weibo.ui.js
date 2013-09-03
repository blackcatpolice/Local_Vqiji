//
// require jquery
// require app.error
// 

(function($) {
  WEIBO.ui = {
    // 旧有兼容
    alert: $.alert,
    confirm: $.confirm,
    errorMessage: App.error.XHRError,
    errorHandler: App.error.handleXHRError
  };
})(jQuery);

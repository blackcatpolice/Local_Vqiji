// require jquery
// require jquery.pjax

/*
  pjax:beforeSend - Fired before the pjax request begins. Returning false will abort the request.
  pjax:send - Fired after the pjax request begins.
  pjax:complete - Fired after the pjax request finishes.
  pjax:success - Fired after the pjax request succeeds.
  pjax:error - Fired after the pjax request fails. Returning false will prevent the the fallback redirect.
  pjax:timeout - Fired if after timeout is reached. Returning false will disable the fallback and will wait indefinitely until the response returns.
*/

if (typeof(__DISABLE_PJAX) === "undefined" || !__DISABLE_PJAX) {
(function($) {
    /* $.pjax.defaults.timeout = 0; */
    $.pjax.defaults.maxCacheLength = 0;

    var pjaxContainer;
    
    // FIXME: 为了解决 pjax 加载时 IE 崩溃的问题，暂时禁用 spin
    function onPjaxSend() {
      //pjaxContainer.spin();
    }

    function onPjaxComplete() {
      //pjaxContainer.spin(false);
    }
    
    function onPjaxError(e, detail) {
      if (detail.statusText !== 'abort') {
        $.alert("加载页面失败！", 2);
        return false;
      }
    }
    
    function onPjaxTimeout() {
      /* NEVER TIMEOUT */
      return false;
    }

    $(document).ready(function() {
      pjaxContainer = $("[data-pjax-container]");

      $(this).pjax("a"
        + ":not([data-remote])"
        + ":not([data-behavior])"
        + ":not([data-skip-pjax])"
        , pjaxContainer);

      $(document)
        .on('pjax:send.app-pjax', onPjaxSend)
        .on('pjax:complete.app-pjax', onPjaxComplete)
        .on('pjax:timeout.app-pjax', onPjaxTimeout)
        .on('pjax:error.app-pjax', onPjaxError);
    });
})(jQuery);
}

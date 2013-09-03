// jQuery.support.msie removed in 1.9+

(function($) {
  $.msie = function(ver) {
    var userAgent = navigator.userAgent;
    
    if (arguments.length == 1) {
      return !!userAgent.match(new Regex("msie " + ver));
    } else {
      return !!userAgent.match(/msie/i)
    }
  }
})(jQuery);

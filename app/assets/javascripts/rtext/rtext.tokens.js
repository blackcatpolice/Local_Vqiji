//
// require jquery
// require jquery.ui.widget
//
(function($) {
  $.widget("rtext.rtextTokens", {
    videoUrlTokens: function() {
      return this.element.find(".video-url");
    }
  });
})(jQuery);

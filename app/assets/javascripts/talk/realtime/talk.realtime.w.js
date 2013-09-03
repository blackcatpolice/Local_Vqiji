// require jquery
// require jquery.ui.widget

(function($, undefined) {
  $.widget("talk.talkW", function() {});

  var W = $.talk.talkW;
  var _w;

  W.instance = function() {
    if (!_w) {
      _w = $(W.TMPL).talkW()
        .appendTo(document.body);
    }
    return _w;
  };

  W.TMPL = '<div class="msg_w"></div>';
})(jQuery);

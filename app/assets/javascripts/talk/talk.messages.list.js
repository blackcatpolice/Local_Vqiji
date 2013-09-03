// require jquery
// require jquery.ui.widget
// require talk/message

(function($) {
  "use strict";
  
  $.widget("talk.talkMessagesList", {
    _create: function() {
      this.prepend_proxy = $.proxy(this.prepend, this);
      API.bind(Talk.api.talkTo, "success", this.prepend_proxy);
      
      this.messages().talkMessage();
    },

    _destroy: function() {
      if (this.prepend_proxy) {
        API.unbind(Talk.api.talkTo, "success", this.prepend_proxy);
      }
      this.messages().talkMessage("destroy");
    },

    messages: function() {
      return $("[data-type=talk-message]", this.element);
    },

    prepend: function(msg) {
      if (this.messages().length == 0) {
        this.element.empty();
      }
      $(msg.html)
        .prependTo(this.element)
        .talkMessage();
      return this;
    }
  });
})(jQuery);

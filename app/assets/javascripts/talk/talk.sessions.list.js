// require jquery
// require jquery.ui.widget
// require talk/session

(function($, undefined) {
  "use strict";
  
  $.widget("talk.talkSessionsList", {
    _create: function() {
      this.prepend_proxy = $.proxy(this.prepend, this);
      API.bind(Talk.api.createSession, "success", this.prepend_proxy);
      this.sessions().talkSession();
    },

    _destroy: function() {
      if (this.prependprepend_proxy) {
        API.unbind(Talk.api.createSession, "success", this.prepend_proxy);
      }
      this.sessions().talkSession("destroy");
    },

    sessions: function() {
      return this.element.find("[data-type=talk-session]");
    },

    prepend: function(session) {
      if (this.sessions().length == 0) {
        this.element.empty();
      }
      $(session.html).talkSession()
        .prependTo(this.element);
      return this;
    }
  });
})(jQuery);

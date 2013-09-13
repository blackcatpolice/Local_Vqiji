(function($) {
  $.widget("talk.talkSession", {
    _create: function() {
      this._on({
        "click [data-action=delete]": this.delete_
      });
    },

    delete_: function() {
      var id = this.element.attr("data-id");
      
      var success = $.proxy(function() {
        this.element.remove();
      }, this);
      
      $.confirm("确认删除这条会话吗？", function(sure) {
        if(sure) {
          Talk.api.deleteSession(id, {
            success: success,
            error: App.error.XHRErrorHandler("删除会话失败！")
          });
        }
      });
    }
  });
})(jQuery);

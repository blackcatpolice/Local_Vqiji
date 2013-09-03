(function($) {
  $.widget("talk.talkSession", {
    options: {
    },
    
    _create: function() {
      this.delete_.proxy = $.proxy(this.delete_, this);
      this.element.on("click", "[data-action=delete]", this.delete_.proxy);
    },
    
    data_id: function() {
      return this.element.attr("data-id");
    },
    
    delete_: function() {
      var id = this.data_id(); if(!id) return;
      var success = $.proxy(function() { this.element.remove(); }, this);
      
      WEIBO.ui.confirm("确认删除这条会话吗？", function(sure) {
        if(sure) {
          Talk.api.deleteSession(id, {
            success: success,
            error: WEIBO.ui.errorHandler
          });
        }
      });
    },
    
    _destroy: function() {
      if (this.delete_.proxy) {
        this.element.off("click", "[data-action=delete]", this.delete_.proxy);
      }
    }
  });
  
})(jQuery);

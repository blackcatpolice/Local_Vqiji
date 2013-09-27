//
// require jquery
// require API

;(function($) {
  "use strict";
  
  window.Todo.api = new function() {
    var context = this;
    
    // 填写任务日志
    this.taskLog = function(id, text, options) {
      var _args = $.merge(API.defaultOptions, {
        type: "POST",
        data: {
          info: text
        }
      });
      
      if (options) {
        var attrs = [ "end_at", "priority", "picture_id", "file_id" ]
          , data = _args.data;
        
        $.each(attrs, function(_, attr) {
          if ( options[attr] ) {
            data[ attr ] = options[attr];
          }
        });
      }
      
      $.extend(true, _args, options);

      return API._request("/todo/tasks/" + id + "/logs.html", _args, context.taskLog);
    };
    
    this.taskProgress = function(id, options) {
      var _args = $.extend(API.defaultOptions, options);
      return API._request("/todo/tasks/" + id + "/progress.json", _args, context.taskProgress);
    };
  };
})(jQuery);

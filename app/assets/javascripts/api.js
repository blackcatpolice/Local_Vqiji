/*
 * API #bind/#unbind
 */
(function($) {
  var API = {
    bind: function(api, event, callback) {
      this._callbacksMap(api, event, true).add(callback);
      return this;
    },
    
    unbind: function(api, event, callback) {
      var cbs = this._callbacksMap(api, event);
      if (cbs) {
        cbs.remove(callback);
      }
      return this;
    },
    
    _wrap: function(api) {
      if ($.isFunction(api)) {
        var methods = {
          bind: function(event, callback) {
            API.bind(api, event, callback);
            return this;
          },
          
          unbind: function(event, callback) {
            API.unbind(api, event, callback);
            return this;
          }
        };
        $.extend(api, methods);
      } else {
        $.error("api should be a function!");      
      }
      return api;
    },
    
    _callbacksMap: function(api, event, create) {
      var key = "api-" + event + "-callbacks";
      var cbs = api[key];
      
      if (!cbs && create) {
        cbs = $.Callbacks("unique");
        api[key] = cbs;
      }
      
      return cbs;
    },
    
    _fire: function(api, event, args) {
      var cbs = this._callbacksMap(api, event);
      if (cbs) cbs.fireWith(this, args);
    },
    
    _request: function(url, options, api) {
      var jqXHR = $.ajax(url, options);
      var context = this;
      jqXHR
        .done(function() { context._fire(api, "success", arguments); })
        .fail(function() { context._fire(api, "error", arguments); })
        .always(function() { context._fire(api, "complete", arguments); });

      return jqXHR;
    },
    
    defaultOptions: {
      type:     "GET",
      dataType: "json",
      cache:    false
    }
  };

  window.API = API;
})(jQuery);

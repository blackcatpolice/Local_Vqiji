// require jquery
// require API

(function($) {
  "use strict";

  App.api = new function() {
    var context = this;
    var _defaultOptions = API.defaultOptions;
    
    // 根据名字查找用户
    this.searchUserByName = function(query, options) {
      var _args = $.extend(true, {}, _defaultOptions, options, {
        method: "GET",
        data: {
          q: query
        },
        cache: true,
        dataType: "json"
      });
      return $.ajax("/users/search.json", _args);
    };
    
    // 获取未读消息数
    this.notificationsCount = function(options) {
      var _args = $.extend(true, {}, _defaultOptions, options, {
        method: "GET",
        cache: false,
        dataType: "json"
      });
      return $.ajax("/notifications/count.json", _args);
    };
  };
})(jQuery);

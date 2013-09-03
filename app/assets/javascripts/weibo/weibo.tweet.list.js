// require jquery
// require jquery.ui.widget
// require weibo.api

(function($) {
  "use strict";
  
  $.widget("weibo.tweetList", {
    options:{
      bindRepost: true,
      bindTweet: true,
      action_name:""
    },

    _create: function() {
      this.prepend_proxy = $.proxy(this.prepend, this);

      if(this.options.bindTweet){
        API.bind(WEIBO.api.tweet, "success", this.prepend_proxy);  
      }
      
      if(this.options.bindRepost){
         API.bind(WEIBO.api.repost, "success", this.prepend_proxy);   
      }

      this.tweets().tweet();
    },

    _destroy: function() {
      if (this.prepend_proxy) {
        API.unbind(WEIBO.api.tweet, "success", this.prepend_proxy);
        API.unbind(WEIBO.api.repost, "success", this.prepend_proxy);
      }
      this.tweets().tweet("destroy");
    },

    tweets: function() {
      return this.element.find("[data-type=Tweet]");
    },

    prepend: function(tweet) {
      if (this.tweets().length == 0) {
        this.element.empty();
      }
      
      var _tweet = $(tweet).tweet();
      var _top = _tweet.tweet("istop");
      var _action_name = this.options.action_name;

      if(
        (_action_name == "") 
        || ( _action_name == "show" ) 
        || ( _action_name == "tops" && _top == true )
      ) {
        this.element.prepend($(_tweet));
      }
      return this;
    }
  });
})(jQuery);

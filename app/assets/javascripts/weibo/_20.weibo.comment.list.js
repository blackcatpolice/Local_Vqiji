//
// 评论列表
//
// require jquery
//

(function($) {
  // 评论列表
  $.widget("weibo.commentList", {
    options: {
      commentOptions: null
    },
    
    _create: function() {
      this.element.find('[data-type=Comment]').comment(this.options.commentOptions);
      
      this._onCommentSuccess_proxy = $.proxy(this._onCommentSuccess, this);
      API.bind(WEIBO.api.sendComment, "success", this._onCommentSuccess_proxy);
    },
    
    _destroy: function() {
      if (this._onCommentSuccess_proxy) {
        API.unbind(WEIBO.api.sendComment, "success", this._onCommentSuccess_proxy);
      }
      this.element.find('[data-type=Comment]').comment("destroy");
    },
    
    _onCommentSuccess: function(comment) {
      if (comment.tweet_id == this._tweetId()) {
        this.prepend(comment);
      }
    },
    
    _tweetId: function() {
      return this.options.tweet_id || this.element.attr("data-tweet-id");
    },
    
    prepend :function(comment){
      if (this.element.find('[data-type=Comment]').length == 0) {
        this.element.empty();
      }
    
      $(comment.html).comment(this.options.commentOptions)
        .prependTo(this.element);
      return this;
    }
  });
})(jQuery);

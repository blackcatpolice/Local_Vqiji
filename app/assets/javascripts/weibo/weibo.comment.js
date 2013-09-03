//
// require jquery
// require rtext.message

(function($, undefined) {
  // 评论
  $.widget("weibo.comment", $.rtext.rtextMessage, {
    options: {
      tweetId:null,
      replayFunc: null,
      replayModal: false
    },
      
    _create: function() {
      this._super();
      
      $.extend(true, this.options, {
        delete_: {
          confirm: "您确认删除这条评论吗？",
          apiFunc: WEIBO.api.deleteComment
        }
      });
      
      this.element.find('[data-action=replay]').click($.proxy(this._replay, this));
    },
    
    _senderName: function() {
      return this.element.attr("data-sender-name");
    },

    _tweetId: function() {
      return this.element.attr("data-tweet-id");
    },

    // 回复
    _replay: function() {
      var context = this,
          _messageId = this._messageId(),
          _senderName = this._senderName();
      var tweetId = this._tweetId();

      /**/
      if(this.options.replayModal){
        var _replayModal = $.weibo.commentReplayModal.create({
          commentId: _messageId,
          tweetId: tweetId,
          senderName: _senderName
        });
        return;
      }
          
      if ($.isFunction(this.options.replayFunc)) {
        this.options.replayFunc.call(this, _messageId, _senderName);
      } else {
          this._trigger("replay", null, {
            commentId: _messageId,
            senderName: _senderName
          });
      }
    }
  });
})(jQuery);

// 嵌入式评论列表
// 包含个评论编辑器

(function($) {
  "use strict";

  $.widget("weibo.commentEmbedList", {
    _create: function() {
      this._super();
      
      this._editor = this.element.find('[data-role=comment-editor]')
        .commentEditor({
          tweet_id: this.element.attr("data-tweet-id"),
          _tmpl: "comment2"
        });

      this._list = this.element.find('[data-role=comment-list]')
        .commentList({
          tweet_id: this.element.attr("data-tweet-id"),
          commentOptions: {
            replayFunc: $.proxy(this._onReplay, this)
          }
        });
    },
    
    _onReplay: function(commentId, senderName) {
      this._editor.commentEditor("replay", commentId, senderName);
    }
  });
})(jQuery);

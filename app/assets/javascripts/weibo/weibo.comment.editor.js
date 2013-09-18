//
// 评论编辑
//
// require jquery
// require rtext.editor
// require rtext.remain_counter
// require weibo

(function($, undefined) {
  $.widget("weibo.commentEditor", $.rtext.rtextEditor, {
    options: {
      recommentId: null,
      _tmpl: "comment",
      preset: "",
      placeHolder: "请在这里输入您的评论",
      tools: ["audio", "emotion"],
      allowBlank: false,
      textMaxLength: 140,
      inputMention: true
    },

    /* 设置被回复的评论Id,txt */
    replay: function(commentId, senderName) {
      this.options.recommentId = commentId;
      this._texter.focus();
      this.text("回复 " + senderName + ":");
      return this;
    },
    
    _tweetId: function() {
      return this.options.tweet_id || this.element.attr("data-tweet-id");
    },

    _submit: function (text, done) {
      var context = this;
      var data = {
        text: text,
        tweet_id: this._tweetId()
      };

      if(this._audioRecorder){
      	var audio = this._audioRecorder.audioRecorder("audio");

        if(audio){
          data.audioId = audio.id;
        }
      }

      if(this.options.recommentId){
        data.recomment_id = this.options.recommentId;
      }
      
      if(this.options._tmpl){
        data._tmpl = this.options._tmpl;
      }

      WEIBO.sendComment(data, {
        success: function(comment) {
          context.reset();
          context.options.recommentId = null;
          done();
          context._trigger("success", null, comment);
        },
        error: function(jqXHR, httpStatus, throwErrors) {
          done();
          App.error.handleXHRError(jqXHR, httpStatus, throwErrors, "发送评论失败！");
        }
      });
    }
  });
})( jQuery );

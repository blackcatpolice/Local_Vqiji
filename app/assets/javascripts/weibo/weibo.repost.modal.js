//
// 微博转发弹出框
//

(function($, undefined) {
  $.widget("weibo.repostModal", {
    options: {
      tweet_id: null,
      autoOpen: true
    },
    
    _create: function() {
    },

    _init: function() {
      if (this.options.autoOpen) {
        this.open();
      }
    },
    
    _initResposter: function() {
      var context = this,
          tweetId = this.options.tweet_id;

      WEIBO.newRepost(tweetId, {
        success: function(html) {
          context._initModal(html).modal("show");
        },
        error: function(jqXHR, httpStatus, throwErrors) {
          $.alert( App.error.XHRError(jqXHR, textStatus, errorThrown, "获取转发信息失败！"), 2 );
        }
      });
    },
    
    open: function() {
      if (this._modal) {
        this._modal.modal("show");
      } else {
        this._initResposter();
      }
      return this;
    },
    
    close: function() {
      if (this._modal) {
        this._modal.modal("hide");
      }
      return this;
    },
    
    _destroy: function() {
      this.close();
    },
    
    _initModal: function(html) {
      var tweetId = this.options.tweet_id;

      this._modal = $(html);
      this._editor = this._modal.find("[data-type=tweet-editor]")
        .reposter({
          tweet:{ id: tweetId },
          toolbarOptions: {
            tip: {
              csses: {
                position: "fixed",
                zIndex: 1060
              }
            }
          },
          success: $.proxy(function() {
            this.close();
          }, this)
        });

      this._modal.on("hide", $.proxy(this._onModalHide, this));
      return this._modal;
    },
    
    _onModalHide: function() {
      // 加快关闭速度
      this._editor.reposter("reset");
      setTimeout($.proxy(function() {
        // this._editor.reposter("destroy");
        this._modal.remove();
      }, this), 50);
    }
  });
})( jQuery );

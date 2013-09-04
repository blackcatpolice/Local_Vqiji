/**/
(function($, undefined) {
	$.widget("weibo.commentReplayModal", {
		options: {
		  commentId: null,
      prepend: false,
		  tweetId: null,
      senderName: null,
		  autoOpen: true
	  },

	  _init: function() {
	    if(!this._modal) {
	      this._initModal();
	    } else {
	      if (this.options.autoOpen) {
	        this.open();
	      }
	    }
	  },
	
	  _destroy: function() {
      if (this._modal) {
        this._off(this._modal, "hide");
        this._modal.remove();
      }
    },
	
    /* init modal */
	  _initModal: function(done) {
	    var self = this;
      var commentId = this.options.commentId;
      var tweetId = this.options.tweetId;
      var senderName = this.options.senderName;
      
      /* call api */
       WEIBO.api.newComment({
          tweet_id: tweetId,
          comment_id: commentId
        }, {
         success: function(tmpl) {
            self._modal = $(tmpl);

            self._editor = self._modal.find("div[data-role=comment-editor]")
              .commentEditor({
                recommentId: commentId,
                toolbarOptions: {
                  tip: {
                    csses: {
                      position: "fixed",
                      zIndex: 1060
                    }
                  }
                },
                success: function() {
                  self.close();
                }
              })
              .commentEditor("replay", commentId, senderName);

            self._on(self._modal, {
              show: function() {
	              this._trigger("open");
              },
              hide: function() {
	              this._trigger("close");
              }
            });

            self._modal.modal({ show: self.options.autoOpen });
          },
          error: App.error.handleXHRError
      });
	  },
    
    open: function() {
      if (this._modal) {
        this._modal.modal("show");
      }
      return this;
    },
    
    close: function() {
      if (this._modal) {
        this._modal.modal("hide");
      }
      return this;
    }
  });
  
  $.weibo.commentReplayModal.create = function(options) {
    var _widget = $("<div></div>").commentReplayModal(options)
      .bind("commentreplaymodalclose", function() {
        _widget.remove();
      });
    return _widget;
  };
})(jQuery);


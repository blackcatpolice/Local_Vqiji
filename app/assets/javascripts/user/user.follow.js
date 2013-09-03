// 用户关注

// require jquery
// require jquery.ui.widget
// require weibo.api (follow/unfollow)

(function($) {
  $.widget("user.follow2", {
    _getCreateOptions: function() {
      var options = $.extend(true, {
          states: this._states()
        }, {
          userId: this.element.data("follow-user"),
           // 已关注 ( false / -1 / 0 / 1 )?
          followed: (this.element.data("followed") === null) ? false : this.element.data("followed"),
          isFan: (this.element.data("is-fan") == true) // 粉丝
        });
      var self = this;
      $.each(["unfollow", "followed-whisper", "followed", "followed-particular",
        "mutual-followed"], function(_, state) {
        var view = self.element.find( "." + state + "-state" );
        if (view.length > 0) {
          options.states[ state ].view = view.remove();
        }
      });
      return options;
    },

    _create: function() {
      if ( !this.options.userId ) {
        $.error("Parameter 'userId' required!");
      }
      // 如果是当前用户隐藏关注按钮
      if (this.options.userId == $CURRENT_USER.id) {
        this.element.hide();
        return;
      }
      this._update();
    },
    
    _destroy: function() {
      if (this._currentState) {
        this._off( this._currentState.view );
        this._currentState.view.remove();
      }
    },
    // 判断状态
    _detectState: function() {
      var state = "unfollow";
      if (this.options.followed !== false) {
         if (this.options.isFan) {
           state = "mutual-followed";
         } else {
          switch(this.options.followed) {
            case -1:
             state = "followed-whisper";
             break;
            case 0: 
             state = "followed";
             break;
            case 1:
             state = "followed-particular";
             break;
          };
        }
      }
      return this.options.states[ state ];
    },
    
    _setCurrentState: function(state) {
      if (this._currentState != state) {
        if (this._currentState) {
          this._off( this._currentState.view );
          // FIXED: 关注后导致 usercard 不能关闭
          // 由于 remove 导致 dom 实际的发生了 mouseleave 而没有触发 mouseleave 事件，
          // 导致 usercard 的 openRetain 计数错误而发生无法正常关闭错误
          this._currentState.view.hide();
        }
        this._currentState = state;
        if (!state.view) {
          state.view = $(state.tmpl);
        }
        state.view.prependTo( this.element ).show();
        this._on( true, state.view, state.on );
      }
    },
    
    _update: function() {
      this._setCurrentState( this._detectState() );
    },
    
    _unFollowMouseEnter: function(e) {
      $(e.currentTarget).find(".follow-types").show();
    },
    
    _unFollowMouseLeave: function(e) {
      $(e.currentTarget).find(".follow-types").hide();
    },
    
    _follow: function() {
      this._follow_(0);
    },
    
    _particularFollow: function() {
      this._follow_(1);
    },
    
    _whisperFollow: function() {
      this._follow_(-1);
    },
    
    _follow_: function(follow_type) {
      var self = this;
  		WEIBO.follow(this.options.userId, follow_type, {
   			success : function(state) {
 				  self.options.followed = state.followed;
 				  self.options.isFan = state.is_fan;
          self._update();
   			},
   			error : function(jqXHR, textStatus, errorThrown) {
          if (textStatus != "abort") {
            var errorMsg = App.error.XHRError.call(this, jqXHR, textStatus, errorThrown, "关注失败！");
            $.alert(errorMsg, 2);
          }
        }
 			});
    },
    
    _unfollow: function() {
      var self = this;
      WEIBO.unfollow(this.options.userId, {
 				success : function(state) {
 				  self.options.followed = state.followed;
 				  self.options.isFan = state.is_fan;
          self._update();
     		},
 				error : function(jqXHR, textStatus, errorThrown) {
          if (textStatus != "abort") {
            var errorMsg = App.error.XHRError.call(this, jqXHR, textStatus, errorThrown, "取消关注失败！");
            $.alert(errorMsg, 2);
          }
        }
			});
    },
    
    _states: function() {
      return {
        // 悄悄关注
        unfollow: {
          tmpl: '<div class="unfollow-state">+ 关注 ^'
                  + '<div class="follow-types hide">'
                    + '<div class="follow">关注</div>'
                    + '<div class="follow-particular">特别关注</div>'
                    + '<div class="follow-whisper">悄悄关注</div>'
                  + '</div>'
                + '</div>',
          on: {
            "mouseenter": this._unFollowMouseEnter,
            "mouseleave": this._unFollowMouseLeave,
            "click .unfollow-state": this._follow,
            "click .follow": this._follow,
            "click .follow-particular": this._particularFollow,
            "click .follow-whisper": this._whisperFollow
          }
        },
        // 已关注
        followed: {
          tmpl: '<div class="followed-state">- 已关注 | <span class="unfollow">取消</span></div>',
          on: {
            "click .unfollow": this._unfollow
          }
        },
        // 特别关注
        "followed-particular": {
          tmpl: '<div class="followed-particular-state">- 特别关注 | <span class="unfollow">取消</span></div>',
          on: {
            "click .unfollow": this._unfollow
          }
        },
        // 悄悄关注
        "followed-whisper": {
          tmpl: '<div class="followed-whisper-state">- 悄悄关注 | <span class="unfollow">取消</span></div>',
          on: {
            "click .unfollow": this._unfollow
          }
        },
        // 相互关注
        "mutual-followed": {
          tmpl: '<div class="mutual-followed-state">- 相互关注 | <span class="unfollow">取消</span></div>',
          on: {
            "click .unfollow": this._unfollow
          }
        }
      };
    }
  });
})(jQuery);

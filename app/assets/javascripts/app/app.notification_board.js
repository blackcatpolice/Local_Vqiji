(function($, App) {
  function NotificationBoard_(trigger) {
    this.$trigger = $(trigger);
    this.init();
  }

  NotificationBoard_.prototype = {
    constructor: NotificationBoard_,

    init: function() {
      this.$trigger.popover(this._getPopoverOptions());
      this.$badge = $("<span class=\"badge\">0</span>").prependTo(this.$trigger);
      this.$trigger
        .on("mouseenter.notify-board", $.proxy(this._onMouseEnter, this))
        .on("mouseleave.notify-board", $.proxy(this._onMouseLeave, this));

      this._$updateBadge = $.proxy(this.updateBadge, this);
      setTimeout(this._$updateBadge, 3000); // 初始化页面后3秒自动更新一次

      this._$onCountChanged = $.proxy(this._onCountChanged, this);
      App.realtime.triggers.register('notificationsCountChanged', this._$onCountChanged);

      // 强制更新 content
      this._forceUpdateContent = true;
    },

    show: function() {
      this.$trigger.popover("show");
    },

    hide: function() {
      this.$trigger.popover("hide");
    },

    destroy: function() {
      App.realtime.triggers.unregister('notificationsCountChanged', this._$onCountChanged);
      
      this.$trigger
        .off(".notify-board")
        .popover("destroy");
      
      if (this.$content) {
        this.$content.off(".notify-board");
        this.$content = null;
      }
    },

    _getPopoverOptions: function() {
      return {
        placement: "bottom",
        animation: true,
        html: true,
        title: '通知中心',
        content: $.proxy(this._getContent, this),
        template: '<div class="popover notify-board"><div class="arrow"></div><div class="popover-content"></div></div>',
        container: 'body'
      };
    },
    
    _onShown: function() {
      this.$content
        .on("mouseenter.notify-board", $.proxy(this._onMouseEnter, this))
        .on("mouseleave.notify-board", $.proxy(this._onMouseLeave, this));

      if (this._isNeedUpdateContent()) {
        this.updateContent();
      }
      this._isShown = true;
    },
    
    _onHidden: function() {
      this.$content.off("mouseenter.notify-board").off("mouseleave.notify-board");
      if (this._isNeedUpdateContent()) {
        this.updateContent();
      }
      this._isShown = false;
    },
    
    _isNeedUpdateContent: function() {
      return (this._forceUpdateContent || this._countChanged);
    },
    
    updateContent: function() {
      if (! this.$content) return;
      var self = this;
      // console.log(this.$content);
      self.$content.spin("small");

      $.ajax("/notifications/board.html", {
        dataType: "html",
        cache: false,
        success: function(notify_board) {
          self.$content.html( notify_board );
        },
        error: function(jqXHR, httpStatus, throwErrors) {
          var errorMsg = App.error.XHRError(jqXHR, httpStatus, throwErrors, "获取未读消息列表失败!");
          self.$content.html( $("<div class=\"error\"></div>").text(errorMsg) );
        },
        complete: function() {
          self._countChanged = self._forceUpdateContent = false;
          self.$content.spin(false);
        }
      });
    },
    
    _getContent: function() {
      if (!this.$content) {
        this.$content = $("<div data-role=\"content\"></div>");
        this.$trigger
          .on("shown.notify-board", $.proxy(this._onShown, this))
          .on("hidden.notify-board", $.proxy(this._onHidden, this));
      }
      return this.$content;
    },
    
    // 更新 badge
    updateBadge: function(force) {
      if (this._updateBadgeXHR) {
        if (!force) {
          return;
        }
        this._updateBadgeXHR.abort();
      };
      
      var self = this;
      
      this._updateBadgeXHR = App.api.notificationsCount({
        success: function(count) {
          self.setBadgeCount(count);
        }/*,
        error: function(jqXHR, textStatus, errorThrown) {
          if (textStatus == "abort") {
            return;
          }
          $.error("fetch notifications count error: " + errorThrown);
        }*/,
        complete: function() {
          self._updateBadgeXHR = null;
        }
      });
    },

    _onCountChanged: function(newCount) {
      this.setBadgeCount(newCount);
      this._countChanged = true;
      if (this._isShown) {
        this.updateContent();
      }
    },
    
    _onMouseEnter: function() {
      if ( this._mouseLeavelHideTimer ) {
        clearTimeout( this._mouseLeavelHideTimer );
        this._mouseLeavelHideTimer = null;
      }
    },
    
    _onMouseLeave: function() {
      if ( this._mouseLeavelHideTimer ) {
        clearTimeout( this._mouseLeavelHideTimer );
      }
      this._mouseLeavelHideTimer = setTimeout( $.proxy(function() {
        this._mouseLeavelHideTimer = null;
        this.hide();
      }, this), 5000 );
    },

    setBadgeCount: function(count) {
      if (count > 0) {
        this.$badge.text(count).addClass("active");
      } else {
        this.$badge.text(0).removeClass("active");
      }
    }
  };
  
  App.NotificationBoard = NotificationBoard_;
})(jQuery, window.App);

// require jquery
// require jquery.ui.widget
// require jquery.tmpl

(function($, Session, Counter, undefined) {
  $.widget("talk.talkRealtimeSidebar", {
    options: {
      mouseLeaveTimeout: 3000
    },
    
    _create: function() {
      this._rc = this.element.find(".msg_rc");
      this._p2pUl = this.element.find("ul[data-role=p2p-ul]").empty();
      this._mmUl = this.element.find("ul[data-role=mm-ul]").empty();
      
      this.hide();

      // 会话项被点击
      this._on(this._p2pUl, { "click li" : this._onItemClick });
      this._on(this._mmUl, { "click li" : this._onItemClick });

      // 调整列表高度
      this._on(window, { resize: this.resizeHeight });

      this._on({
        "click [data-action=active_p2p_ul]": this._activeP2pUl,
        "click [data-action=active_mm_ul]": this._activeMmUl,
        "click [data-action=slide_out]": this.hide,
        
        mouseenter: this._onMouseEnter,
        mouseleave: this._onMouseLeave
      });
      
      // 绑定 Session 相关回调方法
      this._onSessionPrepared_proxy = $.proxy(this._onSessionPrepared, this);
      Session.listen("prepared", this._onSessionPrepared_proxy);
      
      this._onSessionCreated_proxy = $.proxy(this._onSessionCreated, this);
      Session.listen("created", this._onSessionCreated_proxy);
      
      this._onSessionDestroyed_proxy = $.proxy(this._onSessionDestroyed, this);
      Session.listen("destroyed", this._onSessionDestroyed_proxy);

      // 默认显示私信列表
      this._activeP2pUl();
    },
    
    _init: function() {
      this.resizeHeight();
      if (!this._inited) {
        this._inited = true;
        this.hide();
      }
    },
    
    _destroy: function() {
      this._clearMouseLeaveTimeout();
      Session.unlisten("prepared", this._onSessionPrepared_proxy);
      Session.unlisten("created", this._onSessionCreated_proxy);
      Session.unlisten("destroyed", this._onSessionDestroyed_proxy);
      this._off(window, "resize");
    },
    
    /* Session Lifecycle */
    _onSessionPrepared: function(sessions) {
      // 添加在顶部
      this.prepend(sessions);
    },
    
    _onSessionCreated: function(session) {
      this.prepend(session);
    },
    
    _onSessionDestroyed: function(session) {
      // $.alert("您被移除了会话：" + session.title);
      this.remove(session);
    },
    /* \Session Lifecycle */
    
    _onItemClick: function(e) {
      var _item = $(e.target).tmplItem();
      if (_item) {
        var _session = _item.data;
        $.talk.talkWindow.open(_session);
        e.preventDefault();
      }
    },
    
    _activeP2pUl: function() {
      this._p2pUl.show();
      this._mmUl.hide();
      this.element
        .find("[data-action=active_p2p_ul]").addClass("on").end()
        .find("[data-action=active_mm_ul]").removeClass("on");
    },
    
    _activeMmUl: function() {
      this._mmUl.show();
      this._p2pUl.hide();
      this.element
        .find("[data-action=active_mm_ul]").addClass("on").end()
        .find("[data-action=active_p2p_ul]").removeClass("on");
    },
    
    // 添加会话
    append: function(session) {
      this._add.call(this, session, 'append');
      return this;
    },
    
    prepend: function(session) {
      this._add.call(this, session, 'prepend');
      return this;
    },

    _add: function(session, strategy) {
      if ($.isArray(session)) {
        $.each(session, $.proxy(function(_, _session) {
          this._add(_session, strategy);
        }, this));
      } else {
        var self = this;
        var _ul = session.p2p ? this._p2pUl : this._mmUl;
        if (_ul.find("li[data-id=" + session.id + "]").length > 0) {
          return;
        }
        var _item = $.tmpl(''
            + '<li data-id="${id}">'
              + '<span class="badge badge-important hide">0</span>'
              + '<img src="${avatar_url}" />'
              + '<span class="title" title="${title}"><a href="javascript:void(0);">${title}</a></span>'
              + '<span class="subtitle" title="${subtitle}">${subtitle}</span>'
            + '</li>'
          + '', session);

        function _setUnreadCount(count) {
          _item.find(".badge").html(count)[ (count > 0) ? "show" : "hide" ]();
        }

        _ul[ strategy || 'append' ](_item);
        _setUnreadCount(session.unread_count);
        self._setUlUnread(_ul, self._getUlUnread(_ul) + session.unread_count);
        
        session.listen("unread_count-changed", function(value, old) {
          _setUnreadCount(value);
          var count = self._getUlUnread(_ul);
          count += ( value - old );
          self._setUlUnread(_ul, count);
        });
      }
    },
    
    // 删除会话
    remove: function(session) {
      var self = this;
      var _ul = session.p2p ? this._p2pUl : this._mmUl;
      var _item = _ul.find("li[data-id=" + session.id + "]");
      
      if (_item.length > 0) {
        $.talk.talkWindow.instance().talkWindow("remove", session);
        _item.remove();

        self._setUlUnread(_ul, self._getUlUnread(_ul) - session.unread_count );
      }
      return this;
    },
    
    _setUlUnread: function(ul, count) {
      var _tabSelector  = (ul == this._p2pUl) ? "[data-action=active_p2p_ul]" : "[data-action=active_mm_ul]";
      if (count > 0) {
        this.element.find(_tabSelector + " .unread")
            .find(".count").text(count).end()
          .show();
        ul.data("unread", count);
      } else {
        this.element.find(_tabSelector + " .unread")
            .find(".count").text(0).end()
          .hide();
        ul.data("unread", 0);
      }
    },
    
    _getUlUnread: function(ul) {
      return ul.data("unread") || 0;
    },
    
    resizeHeight: function() {
      var h = $(window).height() - 110;
      var mt = h / 2 - 50;
      this._rc.css("height", h);
    },
    
    toggle: function() {
      this[ this.element.is(":visible") ? "hide" : "show" ].call(this);
      return this;
    },

    show: function() {
      if ( this.element.is(":hidden") ) {
        this.element.show();
        // 点击 widget 外的区域会关闭 widget
        this._delay(function() { // 延迟 50 毫秒尽量避免事件冒泡引起的无法显示的问题
          this._on(document.body, {
            click: function() {
              if ( !this._isMouseEnter ) {
                this.hide();
              }
            }
          });
        }, 50);
        this._trigger("shown");
      }
      return this;
    },
    
    hide: function() {
      if ( this.element.is(":visible") ) {
        this.element.hide();
        this._isMouseEnter = false;
        this._off($(document.body), "click");
        this._trigger("hidden");
      }
      return this;
    },
    
    _onMouseEnter: function(e) {
      this._isMouseEnter = true;
      this._clearMouseLeaveTimeout();
    },
    
    _onMouseLeave: function(e) {
      this._isMouseEnter = false;
      this._clearMouseLeaveTimeout();
      this._MouseLeaveTimeout = setTimeout($.proxy(function() {
        this.hide();
      }, this), this.options.mouseLeaveTimeout);
    },
    
    _clearMouseLeaveTimeout: function() {
      if (this._MouseLeaveTimeout) {
        clearTimeout(this._MouseLeaveTimeout);
        this._MouseLeaveTimeout = null;
      }
    }
  });
  
  var Sidebar = $.talk.talkRealtimeSidebar;
  var _sidebar;

  Sidebar.init = function() {
    Sidebar.init = $.noop;
    Sidebar.instance()
      .talkRealtimeSidebar("append", Session.sessions);

    /* floats */
    var floats = $('<div class="msg_zk msg_zk1" style="margin: 10px 10px 0 0;" title="没有未读私信">0</div>')
      .appendTo($.talk.talkW.instance())
      .click(function(e) {
         _sidebar.talkRealtimeSidebar("show");
         e.stopPropagation();
       });

    _sidebar.one("remove", function() {
      Counter.unlisten("changed", updateFloatsText);
      floats.remove();
    });

    updateFloatsText( Counter.unreadsCount() );
    Counter.listen("changed", updateFloatsText);

    function updateFloatsText(count) {
      if (count > 0) {
        floats
          .attr("title", count + "条未读私信")
          .removeClass("msg_zk1")
          .text(count);
      } else {
        floats
          .attr("title", "没有未读私信")
          .addClass("msg_zk1")
          .text(0);
      }
    }
    /* \floats */
  };
  
  Sidebar.TMPL = ''
    + '<div class="msg_r" style="display: none;">'
      + '<div class="msg_rt">'
        + '<a href="javascript:void(0)" data-action="active_p2p_ul" class="on">私信<span class="f12 unread"style="display:none;">（<font color="#dc5f5e" class="count">0</font>）</span></a>'
        + '<a href="javascript:void(0)" data-action="active_mm_ul">多人会话<span class="f12 unread" style="display:none;">（<font color="#dc5f5e" class="count">0</font>）</span></a>'
      + '</div>'
      + '<div class="msg_rc">'
        + '<ul data-role="p2p-ul"></ul>'
        + '<ul data-role="mm-ul" style="display:none;"></ul>'
      + '</div>'
      + '<div class="msg_rd">'
        + '<a href="javascript:void(0)" data-action="slide_out" title="点击隐藏"></a>'
      + '</div>'
    + '</div>';

  Sidebar.instance = function() {
    if (!_sidebar) {
      _sidebar = $(Sidebar.TMPL)
        .talkRealtimeSidebar()
        .appendTo($.talk.talkW.instance());
    }
    return _sidebar;
  };
})(jQuery, Talk.realtime.Session, Talk.realtime.Counter);

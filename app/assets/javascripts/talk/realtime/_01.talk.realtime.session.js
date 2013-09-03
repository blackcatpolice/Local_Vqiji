// 会话

(function($, undefined) {
  function Session_(session) {
    $.extend(session, Session_.prototype);
    
    session._emitter = new io.EventEmitter();
    session._onTalkGroupMessageChanged_proxy = $.proxy(session._onTalkGroupMessageChanged, session);
    
    App.realtime.triggers.register("talkGroupMessageChanged", session._onTalkGroupMessageChanged_proxy);
    App.realtime.triggers.subscribe("weibo:realtime/talk/group/" + session.group_id + "/trigger");
    return session;
  }
  
  $.extend(Session_.prototype, {
    _allowResetUnreadCount: true,
    _active: false,
  
    listen: function(prop, fn) {
      this._emitter.addListener(prop, fn);
    },
    
    unlisten: function(prop, fn) {
      this._emitter.removeListener(prop, fn);
    },
    
    // 设置属性
    _set: function(prop, value) {
      var current = this[prop];
      if (current != value) {
        this[prop] = value;
        //EVENT:  prop-changed
        var event = (prop + "-changed").toLowerCase();
        // old = current
        this._emitter.emit(event, value, current);
      }
    },
    
    send: function(text, options) {
      var _success = options.success
        , _error = options.error
        , self = this;
      
      options.success = function(message) {
        _success.apply(this, arguments);
        // EVENT: message-send-success
        self._emitter.emit("message-send-success", message);
      };
      
      options.error = function() {
        _error.apply(this, arguments);
        // EVENT: message-send-error
        self._emitter.emit("message-send-error", text);
      };
      
      Talk.api.talkTo2(this.id, text, options);
    },
    
    isCurrent: function() {
      return (this == Session_.current);
    },
    
    makeCurrent: function() {
      Session_.makeCurrent(this);
    },
    
    unmakeCurrent: function() {
      if (this == Session_.current) {
        Session_.clearCurrent();
      }
    },

    _setUnreadCount: function(count) {
      this._set("unread_count", count);
    },
    
    _addUnreadCount: function(count) {
      var _count = (this.unread_count || 0) + count;
      this._setUnreadCount(_count);
    },

    // 激活状态
    active: function() {
      this._active = true;
    },
    
    disactive: function() {
      this._active = false;
      this._pullMessages_last_response_at = 0;
    },

    //
    allowResetUnreadCount: function() {
      this._allowResetUnreadCount = true;
    },

    disallowResetUnreadCount: function() {
      this._allowResetUnreadCount = false;
    },

    // 拉取新消息
    pull: function() {
      this[ this._active ? "pullMessages" : "pullUnreadCount" ].apply(this);
    },
    
    // 最后更新时间
    _pullMessages_last_response_at: 0,
    
    // 获取新消息
    // 当 reset_unread_count=false，为了防止重复获取未读的消息，
    // 加入 last-response-at 来标记最后获取时间，将已经获取的消息排除～
    // 
    pullMessages: function() {
      var self = this,
          reset_unread_count = this._allowResetUnreadCount && this.isCurrent();
      Talk.api.fetchUnreadMessages(this.id, {
    	  headers: {
    	    // 最后获取时间
    	    "last-response-at": this._pullMessages_last_response_at
    	  },
        success: function(messages) {
          messages.reverse();
          // EVENT：new-messages-is-comming
          self._emitter.emit("new-messages-is-comming", messages);
          
          // 设置未读消息数
          if(reset_unread_count) {
            self._setUnreadCount(0);
          } else {
            self._addUnreadCount(messages.length);
          }
        },
        // 重置未读状态
        reset_unread_count: reset_unread_count
      }).done(function(data, textStatus, jqXHR) {
        self._pullMessages_last_response_at = jqXHR.getResponseHeader('response-at');
      });
    },
    
    // 重置未读消息状态
    resetUnreadCount: function(count) {
      if (this.unread_count != 0) {
        if (this._allowResetUnreadCount) {
          Talk.api.resetUnreadCount(this.id);
          this._pullTimestamp = null;
        } else {
          $.error("reset unread count not allowed!");
        }
      }
      this._setUnreadCount(0);
    },
    
    // 获取未读消息数
    pullUnreadCount: function() {
      var self = this;
      Talk.api.fetchUnreadCount(this.id, {
        success: function(change) {
          self._setUnreadCount(change.unread_count);
        }
      });
    },
    
    _onTalkGroupMessageChanged: function(group_id, reason) {
      if ( (group_id == this.group_id)
       && (reason && ($CURRENT_USER.id != reason.sender_id)) ) {
        this.pull();
      }
    },
    
    // 获取历史消息
    queryHistroy: $.noop,
    
    destroy: function() {
      App.realtime.triggers.unsubscribe("weibo:realtime/talk/group/" + session.group_id + "/trigger");
      App.realtime.triggers.unregister("talkGroupMessageChanged", this._onTalkGroupMessageChanged_proxy);
    }
  });
  
  var _emitter = new io.EventEmitter();
  
  $.extend(Session_, {
    sessions: [], // 所有托管的会话
    _sessionsMap: {}, // 根据 id 构造的托管会话 map
    current: null, // 当前会话

    // 获取会话列表
    prepare: _prepare,

    _attach: function(session) {
      var _session = this.find(session.id);
      if ( !_session ) {
        this.sessions.push(session)
        this._sessionsMap[session.id] = session;
      }
    },
    
    _detach: function(session) {
      var idx = $.inArray(session, this.sessions);
      if (idx >= 0) {
        this.sessions.splice(idx, 1);
        this._sessionsMap[session.id] = null;
      }
    },
    
    find: function(session_id) {
      return this._sessionsMap[session_id];
    },
    
    listen: function(channel, callback) {
      _emitter.addListener(channel, callback);
    },

    unlisten: function(channel, callback) {
      _emitter.removeListener(channel, callback);
    },
    
    // listen EVENT destroyed
    destroyed: function(callback) {
      this.listen("destroyed", callback);
    },

    // listen EVENT created
    created: function(callback) {
      this.listen("created", callback);
    },
    
    makeCurrent: function (session) {
      if (this.current != session) {
        if (session) {
          Talk.api.makeCurrent(session.id);
          this.current = session;
        } else {
          this.clearCurrent();
        }
      }
    },
    
    clearCurrent: function () {
      if (this.current) {
        Talk.api.clearCurrent();
        this.current = null;
      }
    }
  });

  App.realtime.triggers.register('talkSessionCreated', _sessionCreatedTrigger);
  App.realtime.triggers.register('talkSessionDestroyed', _sessionDestroyedTrigger);
  
  function _prepare(options) {
    var context = Session_;
    
    // 防止重复调用
    context.prepare = $.noop;
    
    var _options = $.extend(true, {}, options, {
      success: function(data) {
        // 包装 session
        $.each(data.sessions, function(_, session) {
          session = Session_(session);
          context._attach(session);
          if (session.id == data.current) {
            context.current = session;
          }
        });
        
        if (options.success) {
          options.success.apply(this, arguments);
        }
        // prepare 只能调用一次！
        _emitter.emit("prepared", context.sessions);
      },
      error: function() {
        context.prepare = _prepare;
      }
    });

    Talk.api.fetchSessions(_options);
  }
  
  function _sessionCreatedTrigger(session_id) {
    // console.log("created session: " + session_id);
    var session = Session_.find(session_id);
    if ( !session ) {
      Talk.api.getSession(session_id, {
        success: function(session) {
          session = Session_(session);
          Session_._attach(session);
          _emitter.emit("created", session);
        }
      });
    }
  }
  
  function _sessionDestroyedTrigger(session_id) {
    // console.log("destroyed session: " + session_id);
    var session = Session_.find(session_id);
    if (session) {
      Session_._detach(session);
      _emitter.emit("destroyed", session);
    }
  }
  
  Talk.realtime.Session = Session_;
})(jQuery);

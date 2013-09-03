// require jquery

// 未读消息计数器
(function($, Session, undefined) {
  var _count = 0
    , _emitter = new io.EventEmitter();

  var Counter_ = {
     // 获取未读消息数
    unreadsCount: function() {
      return _count;
    },
    
    listen: function(channel, callback) {
      _emitter.addListener(channel, callback);
    },

    unlisten: function(channel, callback) {
      _emitter.removeListener(channel, callback);
    },
    
    changed: function(trigger) {
      this._listen("changed", trigger);
    }
  };

  Session.listen("prepared", _onSessionPrepared);
  Session.listen("created", _onSessionCreated);
  Session.listen("destroyed", _onSessionDestroyed);
  
  function _onSessionPrepared(sessions) {
    var old = _count;
    $.each(sessions, function(_, session) {
      session.listen("unread_count-changed", _onUnreadCountChanged);
      _count += session.unread_count;
    });
    if (_count != old) {
      _triggerUnreadCountChanged(_count, old);
    }
  }
  
  function _onSessionCreated(session) {
    session.listen("unread_count-changed", _onUnreadCountChanged);
    if (session.unread_count != 0) {
      var old = _count;
      _count += session.unread_count;
      _triggerUnreadCountChanged(_count, old);
    }
  }

  function _onSessionDestroyed(session) {
    session.unlisten("unread_count-changed", _onUnreadCountChanged);
    if (session.unread_count != 0) {
      var old = _count;
      _count -= session.unread_count;
      _triggerUnreadCountChanged(_count, old);
    }
  }

  function _onUnreadCountChanged(newCount, oldCount) {
    if (newCount != oldCount) {
      var old = _count;
      _count += (newCount - oldCount);
      // console.log("count: " + _count + ", old: " + old);
      _triggerUnreadCountChanged(_count, old);
    }
  }

  function _triggerUnreadCountChanged(count, old) {
    _emitter.emit("changed", count, old);
  }

  Talk.realtime.Counter = Counter_;
})(jQuery, Talk.realtime.Session);


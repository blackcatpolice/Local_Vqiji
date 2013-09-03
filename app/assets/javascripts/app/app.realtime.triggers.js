// require app.realtime

(function($) {
  App.realtime.triggers = {
    _emitter: new io.EventEmitter(),

    // 注册监听器
    register: function(event, callback) {
      this._emitter.addListener(event, callback);
    },
    unregister: function(event, callback) {
      this._emitter.removeListener(event, callback);
    },
    
    // 监听频道
    subscribe: function(channel) {
      App.realtime.subscribe(channel, this._process);
    },
    unsubscribe: function(channel) {
      App.realtime.unsubscribe(channel, this._process);
    },
    
    // 处理收到的频道消息
    _process: function(data) {
      // console.log("App.realtime.triggers#_process: " + data);
      var trigger = $.parseJSON(data);
      var params = [trigger.callback].concat(trigger.params);
      App.realtime.triggers._emitter.emit.apply(App.realtime.triggers._emitter, params);    
    }
  };
})(jQuery);

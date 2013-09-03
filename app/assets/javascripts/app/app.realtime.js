// require jquery
// require socket.io

(function($) {
  var Realtime = function() {
    this.options = {
      host: (window.location.protocol
           + "//"
           + window.location.host.split(":")[0]
           + ":5001")
    };
    this._subscribes = new io.EventEmitter();
  };
  
  // 绑定 subscribe 到 socket
  Realtime.prototype._subscribe = function(channel, callback) {
    if (this.socket) {
      this.socket.emit('subscribe', channel);
      this.socket.on(channel, callback);
    }
  };
  
  // 取消绑定 subscribe 到 socket
  Realtime.prototype._unsubscribe = function(channel, callback) {
    if (this.socket) {
      this.socket.removeListener(channel, callback);
      this.socket.emit('unsubscribe', channel);
    }
  };

  // 绑定 subscribe
  Realtime.prototype.subscribe = function(channel, callback) {
    this._subscribe(channel, callback);
    this._subscribes.addListener(channel, callback);
    return this;
  };
  
  // 取消绑定 subscribe
  Realtime.prototype.unsubscribe = function(channel, callback) {
    this._unsubscribe(channel, callback);
    this._subscribes.removeListener(channel, callback);
    return this;
  };
  
  Realtime.prototype._onconnect = function() {
    this.socket = this._socket_;
    // 绑定 listeners
    if (this._subscribes.$events) {
      var self = this;
      $.each(this._subscribes.$events, function(channel, _) {
        $.each(self._subscribes.listeners(channel), function(_2, callback) {
          self._subscribe(channel, callback);
        });
      });
    }
    this._subscribes.emit('connect');
    // console.debug('REALTIME: connected');
  };
  
  Realtime.prototype._ondisconnect = function(reason) {
    this.socket = null;
    // 删除绑定在 socket 上的listener
    this._socket_.removeAllListeners();
    // console.debug('REALTIME: disconnected');
    this._subscribes.emit('disconnect', reason);
  };
  
  Realtime.prototype.connect = function() {
    /*
      FIXED: 重复 subscribe 同一个 channel
      问题是由于在 socket connecting 时 subscribe 了 channel，
      然后在 connected 后又 subscribe 了一次，导致重复。
      解决方法是引入 _socket_ 变量保存 realtime 创建的 socket，
      在 connect 未完成之前保持 socket(_socket) 为 null, 
      完成之后将 _socket_ 赋值给 socket, 断开链接后将 socket 设置为 null
    */
    if (!this._socket_) {
      this._socket_ = io.connect(this.options.host);
      // why NOT this._socket_?
      // this._socket_ is an instance of SocketNamespace
      // it not call on(connect) again after on(connect) had called once.
      with(this._socket_.socket) {
        on('connect', $.proxy(this._onconnect, this));
        on('disconnect', $.proxy(this._ondisconnect, this));
      }
    } else {
      if (!this._socket_.socket.connected) {
        this._socket_.socket.connect();
      }
    };
    return this;
  };
  
  Realtime.prototype.disconnect = function() {
    if (this._socket_) {
      this._socket_.disconnect();
    }
    return this;
  };

  App.realtime = new Realtime();
})(jQuery);

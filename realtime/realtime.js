var log = require('./logger');

function Realtime(socket, redis) {
  this.socket = socket;
  this.redis = redis;
  
  this.serving = false;
  this.closed = false;
  
  this._onmessage = this._onmessage.bind(this);
  this._onsubscribe = this._onsubscribe.bind(this);
  this._onunsubscribe = this._onunsubscribe.bind(this);
  this._ondisconnect = this._ondisconnect.bind(this);

  this.socket.on("disconnect", this._ondisconnect);
}

Realtime.prototype._onmessage = function(channel, data) {
  this.socket.emit(channel, data);
};

Realtime.prototype._onsubscribe = function(channel) {
  log.debug('REALTIME ---> client subscribe: ' + channel);
  this.redis.subscribe(channel);
};

Realtime.prototype._onunsubscribe = function(channel) {
  log.debug('REALTIME ---> client unsubscribe: ' + channel);
  this.redis.unsubscribe(channel);
};

Realtime.prototype._ondisconnect = function(channel) {
  log.debug('REALTIME ---> disconnect!');
  this._cleanup();
};

Realtime.prototype.serve = function() {
  if (!this.serving && !this.closed) {
    with(this.socket) {
      on("subscribe", this._onsubscribe);
      on("unsubscribe", this._onunsubscribe);
    }
    this.redis.on("message", this._onmessage);
    this.serving = true;
  } else if(this.closed) {
    throw ("realtime had closed!");
  }
  return this;
};

Realtime.prototype.close = function() {
  if (this.serving) {
    this.socket.disconnection();
  } else if(!this.closed()) {
    this.cleanup();
  }
  this.closed = true;
  return this;
};

Realtime.prototype._cleanup = function() {
  with(this.socket) {
    removeListener("message", this._onmessage);
    removeListener("subscribe", this._onsubscribe);
    removeListener("unsubscribe", this._onunsubscribe);
    removeListener("disconnect", this._ondisconnect);
  }
  this.redis.quit();
  delete this.socket;
  delete this.redis;
};

exports.serve = function(client, redis) {
  return new Realtime(client, redis).serve();
}

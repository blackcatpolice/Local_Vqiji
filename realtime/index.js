var config = require('./config'),
    log = require('./logger'),
    server = require('socket.io'),
    Realtime = require('./realtime'),
    Redis = require('redis');

function newRedisClient() {
  var redis = Redis.createClient(config.redis.port, config.redis.host);
  redis.debug_mode = config.debug;
  return redis;
}

var io = server.listen(config.server.port);

io.on('connection', function(client) {
  log.info('REALTIME ---> connection coming!');
  Realtime.serve(client, newRedisClient());
});

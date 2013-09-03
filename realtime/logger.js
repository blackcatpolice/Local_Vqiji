var winston = require('winston')
    config = require('./config');

var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({ json: false, timestamp: true, level: ( config.debug ? 'debug' : 'info' ) }),
    new winston.transports.File({ filename: __dirname + '/../log/realtime.debug.log', json: false })
  ],
  exceptionHandlers: [
    new (winston.transports.Console)({ json: false, timestamp: true, level: ( config.debug ? 'debug' : 'info' ) }),
    new winston.transports.File({ filename: __dirname + '/../log/realtime.exceptions.log', json: false })
  ],
  exitOnError: false
});

module.exports = logger;

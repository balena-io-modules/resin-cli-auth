
/*
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
var Promise, bodyParser, createServer, express, path, utils;

express = require('express');

path = require('path');

bodyParser = require('body-parser');

Promise = require('bluebird');

utils = require('./utils');

createServer = function(_arg) {
  var app, isDev, port, server, _ref;
  _ref = _arg != null ? _arg : {}, port = _ref.port, isDev = _ref.isDev;
  app = express();
  app.use(bodyParser.urlencoded({
    extended: true
  }));
  app.set('view engine', 'ejs');
  app.set('views', path.join(__dirname, 'pages'));
  if (isDev) {
    app.use(express["static"](path.join(__dirname, 'pages', 'static')));
  }
  server = app.listen(port);
  return {
    app: app,
    server: server
  };
};


/**
 * @summary Await for token
 * @function
 * @protected
 *
 * @param {Object} options - options
 * @param {String} options.path - callback path
 * @param {Number} options.port - http port
 *
 * @example
 * server.awaitForToken
 * 	path: '/auth'
 * 	port: 9001
 * .then (token) ->
 *   console.log(token)
 */

exports.awaitForToken = function(options) {
  var app, server, _ref;
  _ref = createServer({
    port: options.port
  }), app = _ref.app, server = _ref.server;
  return new Promise(function(resolve, reject) {
    var closeServer;
    closeServer = function(errorMessage, successPayload) {
      return server.close(function() {
        if (errorMessage) {
          reject(new Error(errorMessage));
          return;
        }
        return resolve(successPayload);
      });
    };
    app.post(options.path, function(request, response) {
      var token, _ref1;
      token = (_ref1 = request.body.token) != null ? _ref1.trim() : void 0;
      return Promise["try"](function() {
        if (!token) {
          throw new Error('No token');
        }
        return utils.isTokenValid(token);
      }).tap(function(isValid) {
        if (!isValid) {
          throw new Error('Invalid token');
        }
      }).then(function() {
        response.status(200).render('success');
        request.connection.destroy();
        return closeServer(null, token);
      })["catch"](function(error) {
        response.status(401).render('error');
        request.connection.destroy();
        return closeServer(error.message);
      });
    });
    return app.use(function(request, response) {
      response.status(404).send('Not found');
      return closeServer('Unknown path or verb');
    });
  });
};

exports.runDevServer = function(_arg) {
  var app, port, server, _ref;
  port = _arg.port;
  _ref = createServer({
    port: port,
    isDev: true
  }), app = _ref.app, server = _ref.server;
  app.get('/success', function(req, res) {
    return res.render('success');
  });
  return app.get('/error', function(req, res) {
    return res.status(401).render('error');
  });
};

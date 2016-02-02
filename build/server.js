
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
var Promise, bodyParser, express, getPagePath, path, utils;

express = require('express');

path = require('path');

bodyParser = require('body-parser');

Promise = require('bluebird');

utils = require('./utils');

getPagePath = function(name) {
  return path.join(__dirname, '..', 'build', 'pages', "" + name + ".html");
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
  var app, server;
  app = express();
  app.use(bodyParser.urlencoded({
    extended: true
  }));
  server = app.listen(options.port);
  return new Promise(function(resolve, reject) {
    app.post(options.path, function(request, response) {
      var token;
      token = request.body.token;
      return utils.isTokenValid(token).then(function(isValid) {
        if (isValid) {
          return response.status(200).sendFile(getPagePath('success'), function() {
            request.connection.destroy();
            return server.close(function() {
              return resolve(token);
            });
          });
        }
        throw new Error('No token');
      })["catch"](function(error) {
        return response.status(401).sendFile(getPagePath('error'), function() {
          request.connection.destroy();
          return server.close(function() {
            return reject(new Error(error.message));
          });
        });
      });
    });
    return app.use(function(request, response) {
      response.status(404).send('Not found');
      server.close();
      return reject(new Error('No token'));
    });
  });
};

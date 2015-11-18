
/*
The MIT License

Copyright (c) 2015 Resin.io, Inc. https://resin.io.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
var Promise, bodyParser, express, getPagePath, path, utils;

express = require('express');

path = require('path');

bodyParser = require('body-parser');

Promise = require('bluebird');

utils = require('./utils');

getPagePath = function(name) {
  return path.join(__dirname, '..', 'pages', "" + name + ".html");
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

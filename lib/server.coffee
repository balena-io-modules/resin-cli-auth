###
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
###

express = require('express')
path = require('path')
bodyParser = require('body-parser')
Promise = require('bluebird')
utils = require('./utils')

getPagePath = (name) ->
	return path.join(__dirname, '..', 'pages', "#{name}.html")

###*
# @summary Await for token
# @function
# @protected
#
# @param {Object} options - options
# @param {String} options.path - callback path
# @param {Number} options.port - http port
#
# @example
# server.awaitForToken
# 	path: '/auth'
# 	port: 9001
# .then (token) ->
#   console.log(token)
###
exports.awaitForToken = (options) ->
	app = express()
	app.use bodyParser.urlencoded
		extended: true

	server = app.listen(options.port)

	return new Promise (resolve, reject) ->
		app.post options.path, (request, response) ->
			token = request.body.token

			utils.isTokenValid(token)
			.then (isValid) ->
				if isValid
					return response.status(200).sendFile getPagePath('success'), ->
						request.connection.destroy()
						server.close ->
							return resolve(token)

				throw new Error('No token')
			.catch (error) ->
				response.status(401).sendFile getPagePath('error'), ->
					request.connection.destroy()
					server.close ->
						return reject(new Error(error.message))

		app.use (request, response) ->
			response.status(404).send('Not found')
			server.close()
			return reject(new Error('No token'))

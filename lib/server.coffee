###
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
###

express = require('express')
path = require('path')
bodyParser = require('body-parser')
Promise = require('bluebird')
utils = require('./utils')

getPagePath = (name) ->
	return path.join(__dirname, 'pages', "#{name}.html")

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
		closeServer = (errorMessage, successPayload) ->
			server.close ->
				if errorMessage
					reject(new Error(errorMessage))
				else
					resolve(successPayload)

		app.post options.path, (request, response) ->
			token = request.body.token?.trim()

			Promise.try ->
				if not token
					throw new Error('No token')
				utils.isTokenValid(token)
			.tap (isValid) ->
				if not isValid
					throw new Error('Invalid token')
			.then ->
				return response.status(200).sendFile getPagePath('success'), ->
					request.connection.destroy()
					server.close ->
						closeServer(null, token)
			.catch (error) ->
				response.status(401).sendFile getPagePath('error'), ->
					request.connection.destroy()
					closeServer(error.message)

		app.use (request, response) ->
			response.status(404).send('Not found')
			server.close()
			return reject(new Error('Unknown path or verb'))

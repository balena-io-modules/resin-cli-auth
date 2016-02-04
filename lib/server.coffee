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
https = require('https')
fs = require('fs')
utils = require('./utils')

CONNECTION_CLOSE_DELAY = 200

getPagePath = (name) ->
	return path.join(__dirname, '..', 'build', 'pages', "#{name}.html")

getCertPath = (file) ->
	return path.join(__dirname, '..', 'certs', file)

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

	# Use self-signed certificate to avoid "unsafe form"
	# errors in some web browsers.
	server = https.createServer({
		key: fs.readFileSync(getCertPath('key.pem'))
		cert: fs.readFileSync(getCertPath('cert.pem'))
	}, app).listen(options.port)

	return new Promise (resolve, reject) ->
		app.all options.path, (request, response) ->
			token = request.body.token

			utils.isTokenValid(token)
			.then (isValid) ->
				if isValid
					return response.status(200).sendFile getPagePath('success'), ->
						setTimeout ->
							request.connection.destroy()
							server.close ->
								return resolve(token)
						, CONNECTION_CLOSE_DELAY

				throw new Error('No token')
			.catch (error) ->
				response.status(401).sendFile getPagePath('error'), ->
					setTimeout ->
						request.connection.destroy()
						server.close ->
							return reject(new Error(error.message))
					, CONNECTION_CLOSE_DELAY

		app.use (request, response) ->
			response.status(404).send('Not found')
			server.close()
			return reject(new Error('No token'))

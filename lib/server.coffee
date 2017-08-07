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

createServer = ({ port, isDev } = {}) ->
	app = express()
	app.use bodyParser.urlencoded
		extended: true

	app.set('view engine', 'ejs')
	app.set('views', path.join(__dirname, 'pages'))

	if isDev
		app.use(express.static(path.join(__dirname, 'pages', 'static')))

	server = app.listen(port)

	return { app, server }

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
	{ app, server } = createServer(port: options.port)

	return new Promise (resolve, reject) ->
		closeServer = (errorMessage, successPayload) ->
			server.close ->
				if errorMessage
					reject(new Error(errorMessage))
					return

				resolve(successPayload)

		app.post options.path, (request, response) ->
			token = request.body.token?.trim()

			Promise.try ->
				if not token
					throw new Error('No token')
				return utils.isTokenValid(token)
			.tap (isValid) ->
				if not isValid
					throw new Error('Invalid token')
			.then ->
				response.status(200).render('success')
				request.connection.destroy()
				closeServer(null, token)
			.catch (error) ->
				response.status(401).render('error')
				request.connection.destroy()
				closeServer(error.message)

		app.use (request, response) ->
			response.status(404).send('Not found')
			closeServer('Unknown path or verb')

exports.runDevServer = ({ port }) ->
	{ app, server } = createServer({ port, isDev: true })

	app.get '/success', (req, res) ->
		res.render('success')

	app.get '/error', (req, res) ->
		res.status(401).render('error')

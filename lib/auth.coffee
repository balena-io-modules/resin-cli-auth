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

###*
# @module auth
###

open = require('open')
resin = require('resin-sdk')
server = require('./server')
utils = require('./utils')

###*
# @summary Login to the Resin CLI using the web dashboard
# @function
# @public
#
# @description
# This function opens the user's default browser and points it
# to the Resin.io dashboard where the session token exchange will
# take place.
#
# Once the the token is retrieved, it's automatically persisted.
#
# @fulfil {String} - session token
# @returns {Promise}
#
# @example
# auth.login().then (sessionToken) ->
#   console.log('I\'m logged in!')
#   console.log("My session token is: #{sessionToken}")
###
exports.login = ->
	options =
		port: 8989
		path: '/auth'

	callbackUrl = "http://localhost:#{options.port}#{options.path}"
	return utils.getDashboardLoginURL(callbackUrl).then (loginUrl) ->

		# Leave a bit of time for the
		# server to get up and runing
		setTimeout ->
			open(loginUrl)
		, 1000

		return server.awaitForToken(options)
			.tap(resin.auth.loginWithToken)

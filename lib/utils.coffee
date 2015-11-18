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

resin = require('resin-sdk')
token = require('resin-token')
_ = require('lodash')
_.str = require('underscore.string')
url = require('url')
Promise = require('bluebird')

###*
# @summary Get dashboard CLI login URL
# @function
# @protected
#
# @param {String} callbackUrl - callback url
# @fulfil {String} - dashboard login url
# @returns {Promise}
#
# @example
# utils.getDashboardLoginURL('http://localhost:3000').then (url) ->
# 	console.log(url)
###
exports.getDashboardLoginURL = (callbackUrl) ->

	# Encode percentages signs from the escaped url
	# characters to avoid angular getting confused.
	callbackUrl = encodeURIComponent(callbackUrl).replace(/%/g, '%25')

	resin.settings.get('dashboardUrl').then (dashboardUrl) ->
		return url.resolve(dashboardUrl, "/login/cli/#{callbackUrl}")

###*
# @summary Check if a token is valid
# @function
# @protected
#
# @description
# This function checks that the token is not only well-structured
# but that it also authenticates with the server successfully.
#
# @param {String} sessionToken - token
# @fulfil {Boolean} - whether is valid or not
# @returns {Promise}
#
# utils.isTokenValid('...').then (isValid) ->
#   if isValid
#     console.log('Token is valid!')
###
exports.isTokenValid = (sessionToken) ->
	if not sessionToken? or _.str.isBlank(sessionToken)
		return Promise.resolve(false)

	return token.get().then (currentToken) ->
		resin.auth.loginWithToken(sessionToken)
			.return(sessionToken)
			.then(resin.auth.isLoggedIn)
			.tap (isLoggedIn) ->
				return if isLoggedIn

				if currentToken?
					return resin.auth.loginWithToken(currentToken)
				else
					return resin.auth.logout()

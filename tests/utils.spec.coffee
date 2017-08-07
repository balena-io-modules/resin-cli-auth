m = require('mochainon')
url = require('url')
Promise = require('bluebird')
resin = require('resin-sdk-preconfigured')
utils = require('../build/utils')
tokens = require('./tokens.json')

describe 'Utils:', ->

	describe '.getDashboardLoginURL()', ->

		it 'should eventually be a valid url', (done) ->
			utils.getDashboardLoginURL('https://localhost:3000/callback').then (loginUrl) ->
				m.chai.expect ->
					url.parse(loginUrl)
				.to.not.throw(Error)
			.nodeify(done)

		it 'should eventually contain an https protocol', (done) ->
			utils.getDashboardLoginURL('https://localhost:3000/callback').then (loginUrl) ->
				protocol = url.parse(loginUrl).protocol
				m.chai.expect(protocol).to.equal('https:')
			.nodeify(done)

		it 'should correctly escape a callback url without a path', ->
			promise = utils.getDashboardLoginURL('http://localhost:3000')
			expectedUrl = 'https://dashboard.resin.io/login/cli/http%253A%252F%252Flocalhost%253A3000'
			m.chai.expect(promise).to.eventually.equal(expectedUrl)

		it 'should correctly escape a callback url with a path', ->
			promise = utils.getDashboardLoginURL('http://localhost:3000/callback')
			expectedUrl = 'https://dashboard.resin.io/login/cli/http%253A%252F%252Flocalhost%253A3000%252Fcallback'
			m.chai.expect(promise).to.eventually.equal(expectedUrl)

	describe '.isTokenValid()', ->

		it 'should eventually be false if token is undefined', ->
			promise = utils.isTokenValid(undefined)
			m.chai.expect(promise).to.eventually.be.false

		it 'should eventually be false if token is null', ->
			promise = utils.isTokenValid(null)
			m.chai.expect(promise).to.eventually.be.false

		it 'should eventually be false if token is an empty string', ->
			promise = utils.isTokenValid('')
			m.chai.expect(promise).to.eventually.be.false

		it 'should eventually be false if token is a string containing only spaces', ->
			promise = utils.isTokenValid('     ')
			m.chai.expect(promise).to.eventually.be.false

		describe 'given the token does not authenticate with the server', ->

			beforeEach ->
				@resinAuthIsLoggedInStub = m.sinon.stub(resin.auth, 'isLoggedIn')
				@resinAuthIsLoggedInStub.returns(Promise.resolve(false))

			afterEach ->
				@resinAuthIsLoggedInStub.restore()

			it 'should eventually be false', ->
				promise = utils.isTokenValid(tokens.johndoe.token)
				m.chai.expect(promise).to.eventually.be.false

			describe 'given there was a token already', ->

				beforeEach (done) ->
					resin.auth.loginWithToken(tokens.janedoe.token).nodeify(done)

				it 'should preserve the old token', (done) ->
					resin.auth.getToken().then (originalToken) ->
						m.chai.expect(originalToken).to.equal(tokens.janedoe.token)
						return utils.isTokenValid(tokens.johndoe.token)
					.then(resin.auth.getToken).then (currentToken) ->
						m.chai.expect(currentToken).to.equal(tokens.janedoe.token)
					.nodeify(done)

			describe 'given there was no token', ->

				beforeEach (done) ->
					resin.auth.logout().nodeify(done)

				it 'should stay without a token', (done) ->
					utils.isTokenValid(tokens.johndoe.token).then ->
						m.chai.expect(resin.token.get()).to.eventually.not.exist
					.nodeify(done)

		describe 'given the token does authenticate with the server', ->

			beforeEach ->
				@resinAuthIsLoggedInStub = m.sinon.stub(resin.auth, 'isLoggedIn')
				@resinAuthIsLoggedInStub.returns(Promise.resolve(true))

			afterEach ->
				@resinAuthIsLoggedInStub.restore()

			it 'should eventually be true', ->
				promise = utils.isTokenValid(tokens.johndoe.token)
				m.chai.expect(promise).to.eventually.be.true

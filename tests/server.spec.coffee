m = require('mochainon')
request = require('request')
Promise = require('bluebird')
path = require('path')
fs = require('fs')
server = require('../lib/server')
utils = require('../lib/utils')
tokens = require('./tokens.json')

options =
	port: 3000
	path: '/auth'

getPage = (name) ->
	pagePath = path.join(__dirname, '..', 'pages', "#{name}.html")
	return fs.readFileSync(pagePath, encoding: 'utf8')

describe 'Server:', ->

	it 'should get 404 if posting to an unknown path', (done) ->
		promise = server.awaitForToken(options)
		m.chai.expect(promise).to.be.rejectedWith('No token')

		request.post "http://localhost:#{options.port}/foobarbaz",
			form:
				token: tokens.johndoe.token
		, (error, response, body) ->
			m.chai.expect(error).to.not.exist
			m.chai.expect(response.statusCode).to.equal(404)
			m.chai.expect(body).to.equal('Not found')
			done()

	it 'should get 404 if not using the correct verb', (done) ->
		promise = server.awaitForToken(options)
		m.chai.expect(promise).to.be.rejectedWith('No token')

		request.get "http://localhost:#{options.port}#{options.path}",
			form:
				token: tokens.johndoe.token
		, (error, response, body) ->
			m.chai.expect(error).to.not.exist
			m.chai.expect(response.statusCode).to.equal(404)
			m.chai.expect(body).to.equal('Not found')
			done()

	describe 'given the token authenticates with the server', ->

		beforeEach ->
			@utilsIsTokenValidStub = m.sinon.stub(utils, 'isTokenValid')
			@utilsIsTokenValidStub.returns(Promise.resolve(true))

		afterEach ->
			@utilsIsTokenValidStub.restore()

		it 'should eventually be the token', (done) ->
			promise = server.awaitForToken(options)
			m.chai.expect(promise).to.eventually.equal(tokens.johndoe.token)

			request.post "http://localhost:#{options.port}#{options.path}",
				form:
					token: tokens.johndoe.token
			, (error, response, body) ->
				m.chai.expect(error).to.not.exist
				m.chai.expect(response.statusCode).to.equal(200)
				m.chai.expect(body).to.equal(getPage('success'))
				done()

	describe 'given the token does not authenticate with the server', ->

		beforeEach ->
			@utilsIsTokenValidStub = m.sinon.stub(utils, 'isTokenValid')
			@utilsIsTokenValidStub.returns(Promise.resolve(false))

		afterEach ->
			@utilsIsTokenValidStub.restore()

		it 'should be rejected', (done) ->
			promise = server.awaitForToken(options)
			m.chai.expect(promise).to.be.rejectedWith('No token')

			request.post "http://localhost:#{options.port}#{options.path}",
				form:
					token: tokens.johndoe.token
			, (error, response, body) ->
				m.chai.expect(error).to.not.exist
				m.chai.expect(response.statusCode).to.equal(401)
				m.chai.expect(body).to.equal(getPage('error'))
				done()

		it 'should be rejected if no token', (done) ->
			promise = server.awaitForToken(options)
			m.chai.expect(promise).to.be.rejectedWith('No token')

			request.post "http://localhost:#{options.port}#{options.path}",
				form:
					token: ''
			, (error, response, body) ->
				m.chai.expect(error).to.not.exist
				m.chai.expect(response.statusCode).to.equal(401)
				m.chai.expect(body).to.equal(getPage('error'))
				done()

		it 'should be rejected if token is malformed', (done) ->
			promise = server.awaitForToken(options)
			m.chai.expect(promise).to.be.rejectedWith('No token')

			request.post "http://localhost:#{options.port}#{options.path}",
				form:
					token: 'asdf'
			, (error, response, body) ->
				m.chai.expect(error).to.not.exist
				m.chai.expect(response.statusCode).to.equal(401)
				m.chai.expect(body).to.equal(getPage('error'))
				done()


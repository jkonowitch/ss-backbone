fs = require('fs')
pathlib = require('path')

module.exports = (responderId, config, ss) ->

	name = config && config.name || 'backbone'

	underscore = fs.readFileSync(__dirname + '/../vendor/lib/underscore-min.js', 'utf8')
	backbone = fs.readFileSync(__dirname + '/../vendor/lib/backbone-min.js', 'utf8')
	backboneSync = fs.readFileSync(__dirname + '/client.' + (process.env['SS_DEV'] && 'coffee' || 'js'), 'utf8')
	ss.client.send('code', 'init', underscore)
	ss.client.send('code', 'init', backbone)
	ss.client.send('code', 'init', backboneSync, {coffee: process.env['SS_DEV']})

	client_api_registration = fs.readFileSync(__dirname + '/register.' + (process.env['SS_DEV'] && 'coffee' || 'js'), 'utf8')
	ss.client.send('mod', 'ss-backbone', client_api_registration, {coffee: process.env['SS_DEV']})
	ss.client.send('code', 'init', "require('ss-backbone')(#{responderId}, {}, require('socketstream').send(#{responderId}));")

	name: name

	interfaces: (middleware) ->

		websocket: (msg, meta, send) ->
			# Get request handler
			request = require('./request')(ss, middleware, config)
			msg = JSON.parse(msg)

			# Expand message fields so they're easier to work with
			model = msg.model

			req =
				modelName:  msg.modelname
				cid:				msg.cid
				method:     msg.method
				socketId:   meta.socketId
				clientIp:   meta.clientIp
				sessionId:  meta.sessionId
				transport:  meta.transport
				receivedAt: Date.now()

			handleError = (e) ->
				message = (meta.clientIp == '127.0.0.1') && e.stack || 'See server-side logs'
				obj = {id: req.id, e: {message: message}}
				ss.log('↩'.red, req.method, e.message.red)
				ss.log(e.stack.split("\n").splice(1).join("\n")) if e.stack
				send(JSON.stringify(obj))

			# Process request
			try
				request model, req, (err, response) ->
					return handleError(err) if err
					timeTaken = Date.now() - req.receivedAt
					ss.log('↩'.green, req.method, "(#{timeTaken}ms)".grey)
					send(JSON.stringify(response))
			catch e
				handleError(e)
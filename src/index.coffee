fs = require('fs')
pathlib = require('path')

module.exports = (responderId, config, ss) ->

	name = config && config.name || 'backbone'

	model_conf = config.models || {}

	file_type = model_conf.file_type || "js"
	model_folder = model_conf.folder || "models"

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

	loadModel = (modelfile) ->
		require(modelfile)(ss)

	interfaces: (middleware) ->

		websocket: (msg, meta, send) ->
			obj = JSON.parse msg
			dir = pathlib.join(ss.root, "server/#{model_folder}")
			modelfile = "#{dir}/#{obj.modelname.toLowerCase()}.#{file_type}"
			ss.log(msg)
			try
			  modelActions = loadModel(modelfile)
			catch e
			  ss.log("Oops. No such model #{modelfile} on the server")
			  send("Oops. No such model #{modelfile} on the server")
			if modelActions && modelActions[obj.method]
				modelActions[obj.method](obj, meta, send)
			else
			  send("Action: '#{obj.method}' not found")
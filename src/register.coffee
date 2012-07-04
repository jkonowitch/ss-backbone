ss = require("socketstream")
module.exports = (responderId, config, send) ->
  ss.registerApi "backbone", (req) ->
    msg = JSON.stringify(req)
    send(msg)
    undefined

  ss.message.on responderId, (msg, meta) ->
    console.log(msg)

# RPC Server-side Request Handler
# -------------------------------
# The RPC handler is only interested in receiving a req object and calling back the res function with (err, response)
# It does not care HOW this request handler is accessed, how to serialize incoming/outgoing messages,
# or how to report errors - that's the job of the interface

pathlib = require('path')

module.exports = (ss, middleware, config) ->

  model_conf = config.models || {}

  file_type = model_conf.file_type || "js"
  model_folder = model_conf.folder || "models"

  dir = pathlib.join(ss.root, "server/#{model_folder}")

  request = (model, req, res) ->

    # Initial error checking
    throw new Error("No action provided. Action names must be a string separated by dots/periods (e.g. 'message.send')") unless req.method && typeof(req.method)

    # Init request stack
    stack = []

    # Allow middleware to be defined
    req.use = (nameOrModule) ->
      try
        args = Array.prototype.slice.call(arguments)

        mw = if typeof(nameOrModule) == 'function'
          nameOrModule
        else
          middlewareAry = nameOrModule.split('.')
          getBranchFromTree(middleware, middlewareAry)

        if mw
          fn = mw.apply(mw, args.splice(1))
          stack.push(fn)
        else
          throw new Error("Middleware function '#{nameOrModule}' not found. Please reference internal or custom middleware as a string (e.g. 'session' or 'user.checkAuthenticated') or pass a function/module")
      catch e
        res(e, null)

    if isArray(model)
      # If a collection is requesting all of the records
      # for a particular model, the 'model' object will be an array
      methodName = "readAll"
    else
      methodName = req.method

    # Create callback t. send to interface
    cb = ->
      args = Array.prototype.slice.call(arguments)
      res(null, args)

    # require file and populate middleware
    actions = require("#{dir}/#{req.modelName.toLowerCase()}.#{file_type}")(req, cb, ss)

    # Execute method at the end of the stack
    main = ->
      # Find the action we're calling
      method = actions[methodName]

      # Warn if this action doesn't exist
      return res(new Error("Unable to find '#{req.method}' method in exports.actions")) unless method?
      return res(new Error("The '#{req.method}' method in exports.actions must be a function")) unless typeof(method) == 'function'

      # Execute action
      method(model)

    # Add RPC call to bottom of middleware stack
    stack.push(main)

    exec = (request, res, i = 0) ->
      stack[i].call stack, req, res, ->
        exec(req, res, i + 1)

    # Execute stack
    exec(req, cb)



# Private

getBranchFromTree = (tree, ary, index = null, i = 0) ->
  index = (ary.length) unless index?
  return tree if i == index
  arguments.callee tree[ary[i]], ary, index, ++i

isArray = (obj) ->
  Object::toString.call(obj) is "[object Array]"

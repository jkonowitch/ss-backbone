memoryStore = {}
ids = 1

module.exports = (req, res, ss) ->

  # Preload session data in to req.session
  req.use('session')

  create: (model) ->
    cid = req.cid
    model.id = ids++
    res =
      cid: cid
      model: model
      method: "confirm"
      modelname: "Todo"

    memoryStore[model.id] = model
    ss.publish.socketId req.socketId, "sync:Todo:" + cid, JSON.stringify(res)
    delete res.cid

    res.method = "create"
    ss.publish.all "sync:Todo", JSON.stringify(res)

  update: (model) ->
    memoryStore[model.id] and (memoryStore[model.id] = model)
    res =
      model: model
      method: "update"
      modelname: "Todo"

    res = JSON.stringify(res)
    ss.publish.all "sync:Todo:" + model.id, res

  read: (model) ->
    fetchedModel = memoryStore[model.id]
    res =
      model: fetchedModel
      method: "read"
      modelname: "Todo"

    ss.publish.socketId req.socketId, "sync:Todo:" + model.id, JSON.stringify(res)

  # For collections requestions all models at once
  readAll: (model) ->
    models = []
    for id of memoryStore
      models.push memoryStore[id]
    res =
      models: models
      method: "read"
      modelname: "Todo"

    ss.publish.socketId req.socketId, "sync:Todo", JSON.stringify(res)

  delete: (model) ->
    if delete memoryStore[model.id]
      res =
        method: "delete"
        model: model
        modelname: "Todo"

      ss.publish.all "sync:Todo:" + model.id, JSON.stringify(res)
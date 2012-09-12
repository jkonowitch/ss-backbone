ids = undefined
memoryStore = undefined
memoryStore = {}
ids = 1
module.exports = (ss) ->
  create: (msg, meta, send) ->
    model = undefined
    res = undefined
    if msg.cid
      model = msg.model
      model.id = ids++
      res =
        cid: msg.cid
        model: model
        method: "confirm"
        modelname: "Todo"

      memoryStore[model.id] = model
      ss.publish.socketId meta.socketId, "sync:Todo:" + msg.cid, JSON.stringify(res)
      delete res.cid

      res.method = "create"
      ss.publish.all "sync:Todo", JSON.stringify(res)

  update: (msg, meta, send) ->
    res = undefined
    memoryStore[msg.model.id] and (memoryStore[msg.model.id] = msg.model)
    res =
      model: msg.model
      method: "update"
      modelname: "Todo"

    res = JSON.stringify(res)
    ss.publish.all "sync:Todo:" + msg.model.id, res

  read: (msg, meta, send) ->
    fetchedModel = undefined
    models = undefined
    res = undefined
    if isArray(msg.model)
      models = []
      for id of memoryStore
        models.push memoryStore[id]
      res =
        models: models
        method: "read"
        modelname: "Todo"

      ss.publish.socketId meta.socketId, "sync:Todo", JSON.stringify(res)
    else
      fetchedModel = memoryStore[msg.model.id]
      res =
        model: fetchedModel
        method: "read"
        modelname: "Todo"

      ss.publish.socketId meta.socketId, "sync:Todo:" + msg.model.id, JSON.stringify(res)

  delete: (msg, meta, send) ->
    if delete memoryStore[msg.model.id]
      res =
        method: "delete"
        model: msg.model
        modelname: "Todo"

      ss.publish.all "sync:Todo:" + msg.model.id, JSON.stringify(res)

isArray = (obj) ->
  Object::toString.call(obj) is "[object Array]"
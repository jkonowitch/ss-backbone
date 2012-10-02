# SS-Backbone

SS-Backbone is a drop-in Backbone library for your SocketStream apps meant for realtime syncing of model data. It is still in the early days, but the goal is to make writing realtime SocketStream Backbone apps a joy by removing a lot of boilerplate setup. Any models you want to sync through a socket will inherit from a syncedModel class, and should be housed by a syncedCollection class (instructions below). All models using these prototypes will fire CRUD events at the server, and will listen for CRUD events from the server, thus keeping all connected clients up to date with the most recent state of the data.

Check out the live app at http://ss-backbone-example.jit.su/ - open in more than one browser to get the 'syncing' effect. The app is essentially copied and pasted from the [TodoMVC](http://todomvc.com) Backbone example app. All I had to do to get this working as a realtime, synced app was to have models/collections inherit from syncedModel and syncedCollection. The code for this example is here: [Todo example code](https://github.com/jkonowitch/ss-backbone/blob/master/examples/todo_example/)

#### Add to your app.js:
	ss.responders.add(require('ss-backbone'));

Or:

    Pass optional config options:
    ss_backbone_opts = {
      models: {
        file_type: "coffee", // default is js
        folder: "backbone_models" // with this option will look in the server/backbone_models folder
                                  // default is server/models
      }
    }
    ss.responders.add(require('ss-backbone'), ss_backbone_opts);

This provides special Model/Collection classes (see below), wires models/collections up to the server through SocketStream's socket connection, and also sends the latest Backbone (0.9.2) and Underscore (1.3.3) production files to the client.

#### Synced Models
Your realtime, synced models inherit from syncedModel and declare modelname on the class:

    myModel = syncedModel.extend( {}, {modelname: "myModel"} );

#### Synced Collections
Realtime, synced collections inherit from syncedCollection and also declare modelname (for now):

    myCollection = syncedCollection.extend( {model: myModel}, {modelname: "myModel"} )

#### On the server [/server/models/mymodel.js]
This is where you decide what to do when CRUD events come in.

I suggest that you read the [Todo example server](https://github.com/jkonowitch/ss-backbone/blob/master/examples/todo_example/server/backbone_models/todo.coffee) for example server logic. Models/Collections are listening for specific events, but these protocols are not yet documented. (coming soon!) See the [ss-backbone models/collections](https://github.com/jkonowitch/ss-backbone/blob/master/src/client.coffee) code for even more detail of how this works.

PS: This is where I'll be focusing on providing some conventions/tools to save developers time and give them more power out of the box.
```cofeescript
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
```
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
This is where you decide what to do when CRUD events come in. See the [Todo example code](https://github.com/jkonowitch/ss-backbone/blob/master/examples/todo_example/) for example server logic. PS: This is where I'll be focusing on providing some conventions/tools to save developers time and give them more power out of the box.

    module.exports = function(ss) {
      	return {
        	create: function(msg, meta, send) {
        		#do stuff
        	},
        	update: function(msg, meta, send) {
        		#do stuff
        	},
        	read: function(msg, meta, send) {
        		#do stuff
        	},
        	delete: function(msg, meta, send) {
        		#do stuff
        	}
        }
    }
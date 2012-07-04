# SS-Backbone

#### Add to your app.js:
	ss.responders.add(require('ss-backbone'));

#### Backbone models inherit from syncedModel and declare modelname on the class:
	myModel = syncedModel.extend( {}, {modelname: "myModel"} );

#### Backbone collections inherit from syncedCollection and also declare modelname (for now):
	myCollection = syncedCollection.extend( {model: myModel}, {modelname: "myModel"} )

#### On the server [/server/models/mymodel.js]
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

#### Check out the ([Todo example code](https://github.com/jkonowitch/ss-backbone/blob/master/examples/todo_example/)) and live app at (http://ss-backbone-example.jit.su/)
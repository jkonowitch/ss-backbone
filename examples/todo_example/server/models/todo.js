var ids, memoryStore;

memoryStore = {};

ids = 1;

module.exports = function(ss) {
  return {
    create: function(msg, meta, send) {
      var model, res;
      if (msg.cid) {
        model = msg.model;
        model.id = ids++;
        res = {
          cid: msg.cid,
          model: model,
          method: "confirm",
          modelname: "Todo"
        };
        memoryStore[model.id] = model;
        ss.publish.socketId(meta.socketId, "sync:Todo:" + msg.cid, JSON.stringify(res));
        delete res.cid;
        res.method = "create"
        return ss.publish.all("sync:Todo", JSON.stringify(res));
      }
    },
    update: function(msg, meta, send) {
      var res;
      memoryStore[msg.model.id] && (memoryStore[msg.model.id] = msg.model)
      res = {
        model: msg.model,
        method: "update",
        modelname: "Todo"
      };
      res = JSON.stringify(res)
      return ss.publish.all("sync:Todo:" + msg.model.id, res);
    },
    read: function(msg, meta, send) {
      var fetchedModel, models, res;
      if (isArray(msg.model)) {
        models = []
        for (id in memoryStore) {
          models.push(memoryStore[id]);
        }
        res = {
          models: models,
          method: "read",
          modelname: "Todo"
        };
        return ss.publish.socketId(meta.socketId, "sync:Todo", JSON.stringify(res));
      } else {
        fetchedModel = memoryStore[msg.model.id]
        res = {
          model: fetchedModel,
          method: "read",
          modelname: "Todo"
        };
        return ss.publish.socketId(meta.socketId, "sync:Todo:" + msg.model.id, JSON.stringify(res));
      }
    },
    delete: function(msg, meta, send) {
      if (delete memoryStore[msg.model.id]) {
        res = {
          method: "delete",
          model: msg.model,
          modelname: "Todo"
        }
        ss.publish.all("sync:Todo:" + msg.model.id, JSON.stringify(res))
      }
    }
  };
};

isArray = function(obj) {
    return Object.prototype.toString.call(obj) == '[object Array]';
  };
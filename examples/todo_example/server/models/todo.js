var ids, memoryStore;

memoryStore = {};

ids = 1;

module.exports = function(req, res, ss) {
  req.use('session');
  return {
    create: function(model) {
      var cid;
      cid = req.cid;
      model.id = ids++;
      res = {
        cid: cid,
        model: model,
        method: "confirm",
        modelname: "Todo"
      };
      memoryStore[model.id] = model;
      ss.publish.socketId(req.socketId, "sync:Todo:" + cid, JSON.stringify(res));
      delete res.cid;
      res.method = "create";
      return ss.publish.all("sync:Todo", JSON.stringify(res));
    },
    update: function(model) {
      memoryStore[model.id] && (memoryStore[model.id] = model);
      res = {
        model: model,
        method: "update",
        modelname: "Todo"
      };
      res = JSON.stringify(res);
      return ss.publish.all("sync:Todo:" + model.id, res);
    },
    read: function(model) {
      var fetchedModel;
      fetchedModel = memoryStore[model.id];
      res = {
        model: fetchedModel,
        method: "read",
        modelname: "Todo"
      };
      return ss.publish.socketId(req.socketId, "sync:Todo:" + model.id, JSON.stringify(res));
    },
    readAll: function(model) {
      var id, models;
      models = [];
      for (id in memoryStore) {
        models.push(memoryStore[id]);
      }
      res = {
        models: models,
        method: "read",
        modelname: "Todo"
      };
      return ss.publish.socketId(req.socketId, "sync:Todo", JSON.stringify(res));
    },
    "delete": function(model) {
      if (delete memoryStore[model.id]) {
        res = {
          method: "delete",
          model: model,
          modelname: "Todo"
        };
        return ss.publish.all("sync:Todo:" + model.id, JSON.stringify(res));
      }
    }
  };
};

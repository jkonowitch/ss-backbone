$ ->
  Todo = syncedModel.extend(
    defaults:
      content: "empty todo..."
      done: false

    toggle: ->
      @set done: not @get("done")
      @save()

    clear: ->
      @destroy()
  , modelname: "Todo")
  TodoList = syncedCollection.extend(
    model: Todo
    done: ->
      @filter (todo) ->
        todo.get "done"

    remaining: ->
      @without.apply this, @done()

    nextOrder: ->
      return 1  unless @length
      @last().get("order") + 1

    comparator: (todo) ->
      todo.get "order"
  , modelname: "Todo")
  Todos = new TodoList
  TodoView = Backbone.View.extend(
    tagName: "li"
    template: -> ss.tmpl["todo-item"]
    events:
      "click .check": "toggleDone"
      "dblclick label.todo-content": "edit"
      "click span.todo-destroy": "clear"
      "keypress .todo-input": "updateOnEnter"
      "blur .todo-input": "close"

    initialize: ->
      _.bindAll this, "render", "close", "remove"
      @model.bind "change", @render
      @model.bind "destroy", @remove

    render: ->
      $(@el).html(@template().render(@model.toJSON()))
      @input = @$(".todo-input")
      this

    toggleDone: ->
      @model.toggle()

    edit: ->
      $(@el).addClass "editing"
      @input.focus()

    close: ->
      @model.save content: @input.val()
      $(@el).removeClass "editing"

    updateOnEnter: (e) ->
      @close()  if e.keyCode is 13

    clear: ->
      @model.clear()
  )
  window.AppView = Backbone.View.extend(
    el: "#todoapp"  
    statsTemplate: -> ss.tmpl["todo-stats"]
    events:
      "keypress #new-todo": "createOnEnter"
      "keyup #new-todo": "showTooltip"
      "click .todo-clear a": "clearCompleted"
      "click .mark-all-done": "toggleAllComplete"

    initialize: ->
      _.bindAll this, "addOne", "addAll", "render", "toggleAllComplete"
      @input = $("#new-todo")
      @allCheckbox = $(".mark-all-done")[0]
      Todos.bind "add", @addOne
      Todos.bind "reset", @addAll
      Todos.bind "all", @render
      Todos.fetch()

    render: ->
      done = Todos.done().length
      remaining = Todos.remaining().length
      @$("#todo-stats").html(@statsTemplate().render(
        total: Todos.length
        done: done
        remaining: remaining
      ))
      @allCheckbox.checked = not remaining

    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$("#todo-list").append view.render().el

    addAll: ->
      Todos.each @addOne

    newAttributes: (content) ->
      content: content
      order: Todos.nextOrder()
      done: false

    createOnEnter: (e) ->
      return  unless e.keyCode is 13
      content = @input.val()
      @input.val("")
      Todos.create @newAttributes(content) unless content == ""
      
    clearCompleted: ->
      _.each Todos.done(), (todo) ->
        todo.clear()

      false

    showTooltip: (e) ->
      tooltip = @$(".ui-tooltip-top")
      val = @input.val()
      tooltip.fadeOut()
      clearTimeout @tooltipTimeout  if @tooltipTimeout
      return  if val is "" or val is @input.attr("placeholder")
      show = ->
        tooltip.show().fadeIn()

      @tooltipTimeout = _.delay(show, 1000)

    toggleAllComplete: ->
      done = @allCheckbox.checked
      Todos.each (todo) ->
        todo.save done: done
  )
  App = new AppView

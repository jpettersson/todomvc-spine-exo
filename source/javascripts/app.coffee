#= require '_lib'
#= require_tree './_todomvc'

TodoItem = require '_todomvc/controllers/todo_item'
Todo = require '_todomvc/models/todo'

class TodoApp extends Exo.Spine.Controller
	ENTER_KEY = 13

	elements:
		'#new-todo':        'newTodoInput'
		'#toggle-all':      'toggleAllElem'
		'#main':			'main'
		'#todo-list':       'todos'
		'#footer':          'footer'
		'#todo-count':      'count'
		'#filters a':       'filters'
		'#clear-completed': 'clearCompleted'

	events:
		'keyup #new-todo':        'new'
		'click #toggle-all':      'toggleAll'
		'click #clear-completed': 'clearCompleted'

	constructor: ->
		super

		@list = new Exo.Spine.List
			el: @todos
			controller: TodoItem

		Todo.bind 'refresh change', @renderList
		Todo.bind 'refresh change', @renderFooter
		Todo.fetch()

		@routes
			'/:filter': (param) ->
				@filter = param.filter
				###
				TODO: Need to figure out why the route doesn't trigger `change` event
				###
				Todo.trigger('refresh')
				@filters.removeClass('selected')
					.filter("[href='#/#{ @filter }']").addClass('selected');

		@activate()

	doActivate: ->
		console.log @el
		TweenLite.to @el, 1,
			css:
				opacity: 1
				marginTop: 130

	new: (e) ->
		val = $.trim @newTodoInput.val()
		if e.which is ENTER_KEY and val
			Todo.create title: val
			@newTodoInput.val ''

	getByFilter: ->
		switch @filter
			when 'active'
				Todo.active()
			when 'completed'
				Todo.completed()
			else
				Todo.all()

	renderList: =>
		@list.render @getByFilter()

	toggleAll: (e) ->
		Todo.each (todo) ->
			###
			TODO: Model updateAttribute sometimes won't stick:
				https://github.com/maccman/spine/issues/219
			###
			todo.updateAttribute 'completed', e.target.checked
			todo.trigger 'update', todo

	clearCompleted: ->
		Todo.destroyCompleted()

	renderFooter: =>
		text = (count) -> if count is 1 then 'item' else 'items'
		active = Todo.active().length
		completed = Todo.completed().length
		@count.html "<strong>#{ active }</strong> #{ text active } left"
		@clearCompleted.text "Clear completed (#{ completed })"


$ ->
	new TodoApp el: $('#todoapp')
	Spine.Route.setup()

class TodoItem extends Exo.Spine.Controller
	ENTER_KEY = 13

	elements:
		'.edit': 'editElem'

	events:
		'click    .destroy': 'remove'
		'click    .toggle':  'toggleStatus'
		'dblclick label':    'edit'
		'keyup    .edit':    'finishEditOnEnter'
		'blur     .edit':    'finishEdit'

	prepareWithModel: (model) ->
		@todo = model
		@todo.bind 'update', @render
		@render()

	render: =>
		@replace JST['_todomvc/views/item'](@todo)
		@

	remove: ->
		@todo.destroy()

	toggleStatus: ->
		@todo.updateAttribute 'completed', !@todo.completed

	edit: ->
		@el.addClass 'editing'
		@editElem.focus()

	finishEdit: ->
		@el.removeClass 'editing'
		val = $.trim @editElem.val()
		if val then @todo.updateAttribute( 'title', val ) else @remove()

	finishEditOnEnter: (e) ->
		@finishEdit() if e.which is ENTER_KEY

	doActivate: ->
		TweenLite.from @el, .2
			css:
				alpha: 0
			onComplete: => @onActivated()

	doDeactivate: ->
		TweenLite.to @el, .2
			css:
				alpha: 0
			onComplete: => @onDeactivated()

module.exports = TodoItem
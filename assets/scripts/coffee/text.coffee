class Text
	MaxStrings = 5

	constructor: (@textField) ->

	addMessage: (message) =>
		console.log textMessage: message unless window.Config.production
		return if message.length == 0

		span = document.createElement 'span'
		span.innerHTML = message

		@textField.appendChild span
		do @textField.children[ 0 ].remove if @textField.children.length > MaxStrings

		@textField.scrollTop = @textField.scrollHeight

		return

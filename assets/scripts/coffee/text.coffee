class Text
	MaxStrings = 200

	constructor: (@textField, @overlay) ->
		@fullscreen = false

		@textField.addEventListener 'pointerdown', @pointerDownHandler
		@textField.addEventListener 'pointerup', @clickHandler
		@overlay.addEventListener 'pointerup', @overlayHandler

	addMessage: (message) =>
		console.log textMessage: message unless window.Config.production
		return if message.length == 0

		span = document.createElement 'span'
		span.innerHTML = message

		@textField.appendChild span
		do @textField.children[ 0 ].remove if @textField.children.length > MaxStrings

		@textField.scrollTop = @textField.scrollHeight

		return

	pointerDownHandler: (event) =>
		@downTime = new Date
		return

	clickHandler: (event) =>
		if !@fullscreen && new Date - @downTime < 200
			@textField.classList.remove 'normal'
			@textField.classList.add 'fullscreen'
			@textField.style.height = "#{ window.innerHeight - 100 }px"
			@textField.scrollTop = @textField.scrollHeight

			@overlay.classList.remove 'hidden'

			@fullscreen = true

		return

	overlayHandler: (event) =>
		@textField.removeAttribute 'style'
		@textField.classList.remove 'fullscreen'
		@textField.classList.add 'normal'
		@textField.scrollTop = @textField.scrollHeight

		@overlay.classList.add 'hidden'

		@fullscreen = false

		return

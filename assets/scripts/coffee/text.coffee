class Text
	MaxStrings = 200

	constructor: (@textField, @overlay) ->
		@fullscreen = false
		@lineIndex = 0

		@textField.addEventListener 'pointerdown', @pointerDownHandler
		@textField.addEventListener 'pointerup', @clickHandler
		@overlay.addEventListener 'pointerup', @overlayHandler

	addMessage: (message) =>
		console.log textMessage: message unless window.Config.production
		return if message.length == 0

		span = document.createElement 'span'
		span.innerHTML = message
		span.classList.add if @lineIndex == 0 then 'even' else 'odd'

		@textField.appendChild span
		do @textField.children[ 0 ].remove if @textField.children.length > MaxStrings

		@textField.scrollTop = @textField.scrollHeight

		@lineIndex ^= 1

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

	resize: => @textField.style.height = "#{ window.innerHeight - 100 }px" if @fullscreen

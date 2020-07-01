class Controller
	rjust = (string, width, padding) ->
		padding ||= ' '
		padding = padding.substr 0, 1
		if string.length < width
			padding.repeat( width - string.length ) + string
		else
			string

	rgbToHex = (command, start) ->
		red = command[ start ]
		green = command[ start + 1 ]
		blue = command[ start + 2 ]

		"\##{ rjust red.toString( 16 ), 2, '0' }#{ rjust green.toString( 16 ), 2, '0' }#{ rjust blue.toString( 16 ), 2, '0' }"

	open = -> console.log 'Socket connected.'

	close = (event) ->
		console.log if event.wasClean then 'Connection successfully closed.' else 'Connection terminated.'
		console.log "Code: #{ event.code }; reason: #{ event.reason }"

	constructor: ->
		host = window.location.href.split( '//' )[ 1 ].split( ':' )[ 0 ]

		@buffer = new Buffer
		@socket = new WebSocket "ws://#{ host }:#{ window.Config.wsPort }"
		@socket.binaryType = 'arraybuffer'
		@socket.onopen = open
		@socket.onclose = close
		@socket.onmessage = @message

	message: (event) =>
		console.log 'Data received:', event.data unless window.Config.production
		view = new DataView event.data
		console.log 'View:', view, view.buffer.byteLength unless window.Config.production

		@buffer.write view

		while command = do @buffer.fetch
			console.log command: command unless window.Config.production

			switch command[ 0 ]
				when 0 then do @resetFieldCommand
				when 1 then do @clearFieldCommand
				when 2
					width = command[ 1 ] * 256 + command[ 2 ]
					height = command[ 3 ] * 256 + command[ 4 ]
					@changeDimensionsCommand width, height
				when 3
					x = command[ 1 ] * 256 + command[ 2 ]
					y = command[ 3 ] * 256 + command[ 4 ]
					hex = rgbToHex command, 5
					@updateBackgroundCommand x, y, hex
				when 4
					x = command[ 1 ] * 256 + command[ 2 ]
					y = command[ 3 ] * 256 + command[ 4 ]
					hex = rgbToHex command, 5
					@addEntityCommand x, y, hex
				when 5
					x = command[ 1 ] * 256 + command[ 2 ]
					y = command[ 3 ] * 256 + command[ 4 ]
					@removeEntityCommand x, y

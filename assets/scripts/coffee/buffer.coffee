class Buffer
	constructor: ->
		@commandsBuffer = []
		@currentCommand = []
		@lastCommandCode = null
		@readCount = 0

		@state = 'init'

	write: (view) ->
		for index in [ 0 ... view.buffer.byteLength ]
			value = view.getUint8 index

			if @lastCommandCode == null
				switch @lastCommandCode = value
					when 0, 1 then @readCount = 0
					when 2 then @readCount = 4
					when 3 then @readCount = 7
					when 4 then @readCount = 7
					when 5 then @readCount = 4
					when 6 then [ @readCount, @state ] = [ 2, 'reading' ]

				if @readCount > 0
					@currentCommand.push @lastCommandCode
				else
					@commandsBuffer.push [ @lastCommandCode ]
					@lastCommandCode = null
			else
				@currentCommand.push value
				@readCount -= 1

				if @readCount == 0
					if @state == 'reading'
						totalData = @currentCommand.length - 1
						@readCount += @currentCommand[ byte + 1 ] << ( ( totalData - byte - 1 ) * 8 ) for byte in [ 0 ... totalData ]
						@state = 'init'

					if @readCount == 0 && @state == 'init'
						@lastCommandCode = null
						@commandsBuffer.push @currentCommand
						@currentCommand = []

		return

	fetch: -> do @commandsBuffer.shift

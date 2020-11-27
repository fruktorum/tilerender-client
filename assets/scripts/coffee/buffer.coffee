class Buffer
	constructor: ->
		@commandsBuffer = []
		@currentCommand = []
		@lastCommandCode = null
		@readCount = 0

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

				if @readCount > 0
					@currentCommand.push @lastCommandCode
				else
					@commandsBuffer.push [ @lastCommandCode ]
					@lastCommandCode = null
			else
				@currentCommand.push value
				@readCount -= 1

				if @readCount == 0
					@lastCommandCode = null
					@commandsBuffer.push @currentCommand
					@currentCommand = []

		return

	fetch: -> do @commandsBuffer.shift

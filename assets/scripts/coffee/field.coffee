class Field
	TileDensityThreshold = 4
	DefaultColor = '#ffffff'

	constructor: (@canvas) ->
		@field = @canvas.getContext '2d'
		@backgroundTiles = []
		@tileWidth = 0
		@tileHeight = 0

	resetField: =>
		@backgroundTiles = []
		do @clearField

	clearField: => @clearTile x, y for y in [ 0 ... @height ] for x in [ 0 ... @width ]

	updateDimensions: (@width, @height) =>
		return if @width <= 0 || @height <= 0

		@backgroundTiles = []

		@canvas.width = window.innerWidth - 20
		@canvas.height = window.innerHeight - 20

		widthDelta = window.innerWidth / @width
		heightDelta = window.innerHeight / @height

		if widthDelta > heightDelta
			@canvas.height = window.innerHeight - 20
			@canvas.width = @canvas.height * @width / @height
		else
			@canvas.width = window.innerWidth - 20
			@canvas.height = @canvas.width * @height / @width

		@tileWidth = @canvas.width / @width
		@tileHeight = @canvas.height / @height

		(->
			@fillStyle = '#808080'
			do @beginPath
			@moveTo 0, 0
			@lineTo 0, @canvas.height
			@lineTo @canvas.width, @canvas.height
			@lineTo @canvas.width, 0
			@lineTo 0, 0
			do @stroke
		).call @field

		if @tileWidth > TileDensityThreshold
			for position in [ 1 ... @width ]
				delimiter = @tileWidth * position
				@line delimiter, 0, delimiter, @canvas.height, '#808080'

		if @tileHeight > TileDensityThreshold
			for position in [ 1 ... @height ]
				delimiter = @tileHeight * position
				@line 0, delimiter, @canvas.width, delimiter, '#808080'

		console.log 'Field dimensions reset', @width, @height unless window.Config.production

	updateBackground: (x, y, color) =>
		if x < 0 || y < 0 || x > @width - 1 || y > @height - 1
			console.error "Background index out of bounds"
			return

		offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + offsetX, y * @tileHeight + offsetY, @tileWidth - offsetX * 2, @tileHeight - offsetY * 2

		@backgroundTiles[ y ] ||= []
		@backgroundTiles[ y ][ x ] = color

		console.log 'Update background color', x: x, y: y, color: color unless window.Config.production

	addEntity: (x, y, color) =>
		if x < 0 || y < 0 || x > @width - 1 || y > @height - 1
			console.error "Entity index out of bounds"
			return

		offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + offsetX, y * @tileHeight + offsetY, @tileWidth - offsetX * 2, @tileHeight - offsetY * 2

		console.log 'Draw entity', x: x, y: y, color: color unless window.Config.production

	clearTile: (x, y) =>
		offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@field.fillStyle = @backgroundTiles[ y ] && @backgroundTiles[ y ][ x ] || DefaultColor
		@field.fillRect x * @tileWidth + offsetX, y * @tileHeight + offsetY, @tileWidth - offsetX * 2, @tileHeight - offsetY * 2

		console.log 'Clear tile', x, y unless window.Config.production

	line: (startX, startY, finishX, finishY, color) ->
		@field.fillStyle = color
		do @field.beginPath
		@field.moveTo startX, startY
		@field.lineTo finishX, finishY
		do @field.stroke

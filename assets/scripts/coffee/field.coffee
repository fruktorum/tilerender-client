class Field
	TileDensityThreshold = 4
	DefaultColor = '#ffffff'

	indexError = (entityType, x, y, width, height) -> console.error "#{ entityType } index out of bounds: (#{ x }, #{ y }) > (#{ width - 1 }, #{ height - 1 })"

	borders = (canvas, field) ->
		field.fillStyle = '#808080'
		do field.beginPath
		field.moveTo 0, 0
		field.lineTo 0, canvas.height
		field.lineTo canvas.width, canvas.height
		field.lineTo canvas.width, 0
		field.lineTo 0, 0
		do field.stroke

	line = (field, startX, startY, finishX, finishY, color) ->
		field.fillStyle = color
		do field.beginPath
		field.moveTo startX, startY
		field.lineTo finishX, finishY
		do field.stroke

	constructor: (@canvas) ->
		@field = @canvas.getContext '2d'
		@backgroundTiles = []
		@width = @height = @tileWidth = @tileHeight = 0

	resetField: =>
		@backgroundTiles = []

		@field.fillStyle = DefaultColor
		@field.fillRect x * @tileWidth + @offsetX, y * @tileHeight + @offsetY, @rectWidth, @rectHeight for y in [ 0 ... @height ] for x in [ 0 ... @width ]

		console.log 'Reset field' unless window.Config.production

	clearField: =>
		@clearTile x, y, false for y in [ 0 ... @height ] for x in [ 0 ... @width ]
		console.log 'Clear field' unless window.Config.production

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

		@offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		@offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@rectWidth = @tileWidth - @offsetX * 2
		@rectHeight = @tileHeight - @offsetY * 2

		borders @canvas, @field

		if @tileWidth > TileDensityThreshold
			for position in [ 1 ... @width ]
				delimiter = @tileWidth * position
				line @field, delimiter, 0, delimiter, @canvas.height, '#808080'

		if @tileHeight > TileDensityThreshold
			for position in [ 1 ... @height ]
				delimiter = @tileHeight * position
				line @field, 0, delimiter, @canvas.width, delimiter, '#808080'

		console.log 'Field dimensions reset', @width, @height unless window.Config.production

	updateBackground: (x, y, color) =>
		if x < 0 || y < 0 || x > @width - 1 || y > @height - 1
			indexError 'Background', x, y, @width, @height
			return

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + @offsetX, y * @tileHeight + @offsetY, @rectWidth, @rectHeight

		@backgroundTiles[ y ] ||= []
		@backgroundTiles[ y ][ x ] = color

		console.log 'Update background color', x: x, y: y, color: color unless window.Config.production

	addEntity: (x, y, color) =>
		if x < 0 || y < 0 || x > @width - 1 || y > @height - 1
			indexError 'Entity', x, y, @width, @height
			return

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + @offsetX, y * @tileHeight + @offsetY, @rectWidth, @rectHeight

		console.log 'Draw entity', x: x, y: y, color: color unless window.Config.production

	clearTile: (x, y, log = !window.Config.production) =>
		@field.fillStyle = @backgroundTiles[ y ] && @backgroundTiles[ y ][ x ] || DefaultColor
		@field.fillRect x * @tileWidth + @offsetX, y * @tileHeight + @offsetY, @rectWidth, @rectHeight
		console.log 'Clear tile', x, y if log

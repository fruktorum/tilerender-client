class Field
	TileDensityThreshold = 4
	DefaultColor = '#ffffff'

	indexError = (entityType, x, y, width, height) ->
		console.error "#{ entityType } index out of bounds: (#{ x }, #{ y }) > (#{ width - 1 }, #{ height - 1 })"
		return

	borders = (canvas, field) ->
		field.fillStyle = '#808080'
		do field.beginPath
		field.moveTo 0, 0
		field.lineTo 0, canvas.height
		field.lineTo canvas.width, canvas.height
		field.lineTo canvas.width, 0
		field.lineTo 0, 0
		do field.stroke
		return

	line = (field, startX, startY, finishX, finishY, color) ->
		field.fillStyle = color
		do field.beginPath
		field.moveTo startX, startY
		field.lineTo finishX, finishY
		do field.stroke
		return

	constructor: (@canvas) ->
		@field = @canvas.getContext '2d'
		@backgroundTiles = []
		@foregroundTiles = []
		@width = @height = @tileWidth = @tileHeight = 0

	resetField: =>
		@backgroundTiles = []
		@foregroundTiles = []

		@field.fillStyle = DefaultColor
		@field.fillRect x * @tileWidth + 1, y * @tileHeight + 1, @rectWidth, @rectHeight for y in [ 0 ... @height ] for x in [ 0 ... @width ]

		console.log 'Reset field' unless window.Config.production
		return

	clearField: =>
		@clearTile x, y, false for y in [ 0 ... @height ] for x in [ 0 ... @width ]
		console.log 'Clear field' unless window.Config.production
		return

	updateDimensions: (@width, @height) =>
		return indexError 'Dimensions', @width, @height, @width, @height if @width <= 0 || @height <= 0

		@backgroundTiles = []
		@foregroundTiles = []

		element = @canvas.parentElement

		widthDelta = Math.floor element.clientWidth / @width
		heightDelta = Math.floor element.clientHeight / @height

		if widthDelta > heightDelta
			correctedHeight = element.clientHeight - 4
			@tileHeight = Math.floor correctedHeight / @height
			@tileWidth = Math.floor correctedHeight / @height
		else
			correctedWidth = element.clientWidth - 4
			@tileWidth = Math.floor correctedWidth / @width
			@tileHeight = Math.floor correctedWidth / @width

		@tileWidth = Math.max @tileWidth, 1
		@tileHeight = Math.max @tileHeight, 1

		offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@canvas.width = @tileWidth * @width + 2 - offsetX * 2
		@canvas.height = @tileHeight * @height + 2 - offsetY * 2

		@rectWidth = Math.max @tileWidth - offsetX * 2, 1
		@rectHeight = Math.max @tileHeight - offsetY * 2, 1

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
		return

	updateBackground: (x, y, color) =>
		return indexError 'Background', x, y, @width, @height if x < 0 || y < 0 || x > @width - 1 || y > @height - 1

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + 1, y * @tileHeight + 1, @rectWidth, @rectHeight

		@backgroundTiles[ y ] ||= []
		@backgroundTiles[ y ][ x ] = color

		console.log 'Update background color', x: x, y: y, color: color unless window.Config.production
		return

	addEntity: (x, y, color) =>
		return indexError 'Entity', x, y, @width, @height if x < 0 || y < 0 || x > @width - 1 || y > @height - 1

		@field.fillStyle = color
		@field.fillRect x * @tileWidth + 1, y * @tileHeight + 1, @rectWidth, @rectHeight

		@foregroundTiles[ y ] ||= []
		@foregroundTiles[ y ][ x ] = color

		console.log 'Draw entity', x: x, y: y, color: color unless window.Config.production
		return

	clearTile: (x, y, log = !window.Config.production) =>
		return indexError 'Clear', x, y, @width, @height if x < 0 || y < 0 || x > @width - 1 || y > @height - 1

		@field.fillStyle = @backgroundTiles[ y ] && @backgroundTiles[ y ][ x ] || DefaultColor
		@field.fillRect x * @tileWidth + 1, y * @tileHeight + 1, @rectWidth, @rectHeight

		@foregroundTiles[ y ] ||= []
		@foregroundTiles[ y ][ x ] = null

		console.log 'Clear tile', x, y if log
		return

	resize: =>
		backgroundTilesCache = @backgroundTiles
		foregroundTilesCache = @foregroundTiles

		@updateDimensions @width, @height

		for row, y in backgroundTilesCache
			if row
				for color, x in row
					@updateBackground x, y, color if color

		for row, y in foregroundTilesCache
			if row
				for color, x in row
					@addEntity x, y, color if color

		return

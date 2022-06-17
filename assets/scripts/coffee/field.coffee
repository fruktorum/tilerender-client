TileDensityThreshold = 4
DefaultColor = '#ffffff'

indexError = (entityType, x, y, width, height) ->
	console.error "#{ entityType } index out of bounds: (#{ x }, #{ y }) > (#{ width - 1 }, #{ height - 1 })"
	return

borders = (canvas, field) ->
	field.strokeStyle = '#808080'
	do field.beginPath
	field.moveTo 0, 0
	field.lineTo 0, canvas.height
	field.lineTo canvas.width, canvas.height
	field.lineTo canvas.width, 0
	field.lineTo 0, 0
	do field.stroke
	return

line = (field, startX, startY, finishX, finishY, color) ->
	field.strokeStyle = color
	do field.beginPath
	field.moveTo startX, startY
	field.lineTo finishX, finishY
	do field.stroke
	return

export default class Field
	constructor: (@canvas) ->
		@field = @canvas.getContext '2d'
		@backgroundTiles = []
		@foregroundTiles = []
		@width = @height = @tileWidth = @tileHeight = 0
		@drawLines = true

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

		widthDelta = element.clientWidth // @width
		heightDelta = element.clientHeight // @height

		if widthDelta > heightDelta
			correctedHeight = element.clientHeight - 4
			@tileHeight = correctedHeight // @height
			@tileWidth = correctedHeight // @height
		else
			correctedWidth = element.clientWidth - 4
			@tileWidth = correctedWidth // @width
			@tileHeight = correctedWidth // @width

		@tileWidth = Math.max @tileWidth, 1
		@tileHeight = Math.max @tileHeight, 1

		offsetX = if @tileWidth > TileDensityThreshold then 1 else 0
		offsetY = if @tileHeight > TileDensityThreshold then 1 else 0

		@canvas.width = @tileWidth * @width + 2 - offsetX * 2
		@canvas.height = @tileHeight * @height + 2 - offsetY * 2

		offsetX = if @drawLines && offsetX == 1 then 1 else 0
		offsetY = if @drawLines && offsetY == 1 then 1 else 0

		@rectWidth = Math.max @tileWidth - offsetX * 2, 1
		@rectHeight = Math.max @tileHeight - offsetY * 2, 1

		borders @canvas, @field

		if @drawLines
			if @tileWidth > TileDensityThreshold
				for position in [ 1 ... @width ]
					delimiter = @tileWidth * position
					line @field, delimiter, 0, delimiter, @canvas.height, '#707070'

			if @tileHeight > TileDensityThreshold
				for position in [ 1 ... @height ]
					delimiter = @tileHeight * position
					line @field, 0, delimiter, @canvas.width, delimiter, '#707070'

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

	toggleLines: (value) =>
		@drawLines = value
		do @resize if @width > 0 && @height > 0
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

window.onload = -> (->
	field = new Field document.getElementById 'field'
	@resetFieldCommand = field.resetField
	@clearFieldCommand = field.clearField
	@changeDimensionsCommand = field.updateDimensions
	@updateBackgroundCommand = field.updateBackground
	@addEntityCommand = field.addEntity
	@removeEntityCommand = field.clearTile
).call new Controller

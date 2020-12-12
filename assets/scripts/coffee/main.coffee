window.onload = -> (->
	field = new Field document.getElementById 'field'
	text = new Text document.getElementById 'text'

	@resetFieldCommand = field.resetField
	@clearFieldCommand = field.clearField
	@changeDimensionsCommand = field.updateDimensions
	@updateBackgroundCommand = field.updateBackground
	@addEntityCommand = field.addEntity
	@removeEntityCommand = field.clearTile

	@addMessageCommand = text.addMessage
).call new Controller

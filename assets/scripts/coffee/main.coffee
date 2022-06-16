import Controller from './controller'
import Field from './field'
import Text from './text'

window.onload = -> (->
	field = new Field document.getElementById 'field'
	text = new Text document.getElementById( 'text' ), document.getElementById( 'overlay' )

	@resetFieldCommand = field.resetField
	@clearFieldCommand = field.clearField
	@changeDimensionsCommand = field.updateDimensions
	@updateBackgroundCommand = field.updateBackground
	@addEntityCommand = field.addEntity
	@removeEntityCommand = field.clearTile
	@toggleLinesCommand = field.toggleLines

	@addMessageCommand = text.addMessage

	window.onresize = ->
		do field.resize
		do text.resize
		return

	return
).call new Controller

extends Control


var tablePlugin
# Called when the node enters the scene tree for the first time.
func _ready():
	tablePlugin = $AceTable
	
	var textRect = TextureRect.new()
	textRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	textRect.size_flags_horizontal = SIZE_EXPAND_FILL
	textRect.set_texture(load("res://icon.svg"))
	
	var colDefs = {
		"foo":{
			"columnId": "foo",
			"columnName": "Foo",
			"columnSort": true,
			"columnType": AceTableConstants.ColumnType.LABEL,
			"columnAlign": AceTableConstants.Align.CENTER
		},
		"bar":{
			"columnId": "bar",
			"columnName": "Bar",
			"columnSort": true,
			"columnType": AceTableConstants.ColumnType.BUTTON,
			"columnImage": "res://icon.svg",
			"columnFunc": button_pressed.bind("Test"),
			"columnAlign": AceTableConstants.Align.CENTER
			
		},
		"foobar":{
			"columnId": "foobar",
			"columnName": "FooBar",
			"columnType": AceTableConstants.ColumnType.TEXTURE_RECT,
			"columnAlign": AceTableConstants.Align.CENTER,
			"columnNode": textRect
			
		},
	}
	
	var data = [
		{
			"foo":"12",
			"bar":"Press Me",
			"foobar": "res://icon.svg"
		},
		{
			"foo":"15",
			"bar":"Old Me",
			"foobar": "res://icon.svg"
		},
		{
			"foo":"10",
			"bar":"Press Me",
			"foobar": "res://icon.svg"
		},
		{
			"foo":"17",
			"bar":"New Me",
			"foobar": "res://icon.svg"
		}
	]
	
	AceTableManager.createTable(tablePlugin, colDefs, data)
	

func button_pressed(var1: String):
	print("Arg1 from Button: %s" % [var1])

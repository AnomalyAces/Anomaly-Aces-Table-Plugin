extends HBoxContainer

const AceTableConfig = preload("res://addons/anomalyAcesTable/Scripts/Table/AceTableConfig.gd")
const AceTablePlugin = preload("res://addons/anomalyAcesTable/Scripts/ace_table_properties.gd")
const AceTableColumnDef = preload("res://addons/anomalyAcesTable/Scripts/Table/AceTableColumnDef.gd")
const Cell = preload("res://addons/anomalyAcesTable/Scripts/Table/Cell.gd")

signal pressed

var data: Dictionary

func _init(plugin: AceTablePlugin, cfg: AceTableConfig, rowScene: HBoxContainer, dt: Dictionary = {}):
	if(plugin == null || cfg == null):
		return
	
	data = dt
	rowScene.add_theme_constant_override("separation", plugin.cell_separation)
	
	for colDef in cfg.columnDefs:
		var cell: Cell = Cell.new()
		match colDef.columnType:
			AceTableConstants.ColumnType.LABEL:
				var label: Label = _getLabelFromConfig(colDef,data)
				rowScene.add_child(cell.compose_cell(plugin.row_cell_theme, label))
			AceTableConstants.ColumnType.BUTTON:
				var button: BaseButton = _getButtonFromConfig(colDef, data)
				rowScene.add_child(cell.compose_cell(plugin.row_cell_theme, button))
			AceTableConstants.ColumnType.TEXTURE_RECT:
				var image = _getTextureRectFromConfig(colDef, data)
				rowScene.add_child(cell.compose_cell(plugin.row_cell_theme, image))
			_:
				push_error("Column Def %s column type %s is unknown" % [colDef, colDef.columnType])
	
	
func _getLabelFromConfig(colDef: AceTableColumnDef, dt: Dictionary) -> Label:
	var label: Label
	if(colDef.columnNode != null):
		label = colDef.columnNode.duplicate()
		label.name = colDef.columnId
		label.text = dt[colDef.columnId]
	else:
		label = Label.new()
		label.text = dt[colDef.columnId]
		label.name = colDef.columnId
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.size_flags_vertical = SIZE_EXPAND_FILL
		label.horizontal_alignment = colDef.columnAlign
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	return label	

func _getButtonFromConfig(colDef: AceTableColumnDef, dt: Dictionary) -> BaseButton: 
	var button: Button
	
	if(colDef.columnNode != null):
		button = colDef.columnNode.duplicate()
		button.name = colDef.columnId
		button.text = dt[colDef.columnId]
	else:
		button = Button.new()
		button.text = dt[colDef.columnId]
		button.name = colDef.columnId
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.alignment = colDef.columnAlign
		button.connect("pressed", _on_Button_pressed.bind(colDef.columnFunc))
		if(!colDef.columnImage.is_empty()):
			button.set_button_icon(load(colDef.columnImage))
		
	return button

func _getTextureRectFromConfig(colDef: AceTableColumnDef, dt: Dictionary) -> TextureRect:
	var textureRect: TextureRect
	if(colDef.columnNode != null):
		textureRect = colDef.columnNode.duplicate()
		textureRect.name = colDef.columnId
	else:
		textureRect = TextureRect.new()
		textureRect.name = colDef.columnId
		textureRect.size_flags_horizontal = SIZE_EXPAND_FILL
		textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		textureRect.set_texture(load(dt[colDef.columnId]))
	return textureRect

func _on_Button_pressed(callable: Callable):
	callable.call()
	pressed.emit()

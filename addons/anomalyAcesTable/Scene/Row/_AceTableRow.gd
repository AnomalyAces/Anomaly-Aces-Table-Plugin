@tool
class_name _AceTableRow extends HBoxContainer

const _ace_table_button_scene = preload("res://addons/anomalyAcesTable/Scene/Button/_AceTableButton.tscn")

signal pressed

var data: Dictionary

func _init(plugin: AceTable, cfg: _AceTableConfig, rowScene: HBoxContainer, dt: Dictionary = {}):
	if(plugin == null || cfg == null):
		return
	
	data = dt
	rowScene.add_theme_constant_override("separation", plugin.cell_separation)
	
	for colDef in cfg.columnDefs:
		var cell: _AceTableCell = _AceTableCell.new()
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
				AceLog.printLog(["Column Def %s column type %s is unknown" % [colDef, colDef.columnType]], AceLog.LOG_LEVEL.ERROR)
	
	
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
		label.horizontal_alignment = int(colDef.columnAlign) if colDef.columnAlign != -1 else int(AceTableConstants.Align.CENTER)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	return label	

func _getButtonFromConfig(colDef: AceTableColumnDef, dt: Dictionary) -> BaseButton: 
	var button: _AceTableButton
	
	if(colDef.columnNode != null):
		button = colDef.columnNode.duplicate()
		button.name = colDef.columnId
		button.text = dt[colDef.columnId]
	else:
		button = _ace_table_button_scene.instantiate()
		button._button_text = dt[colDef.columnId]
		button.name = colDef.columnId
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button._button_text_alignment = int(colDef.columnAlign) if colDef.columnAlign != -1 else int(AceTableConstants.Align.CENTER)
		button.connect("pressed", _on_Button_pressed.bind(colDef, dt))
		if(!colDef.columnImage.is_empty()):
			button._button_icon_size = colDef.columnImageSize
			button._button_icon = load(colDef.columnImage)
		button.is_right_icon = colDef.columnImageAlign == AceTableConstants.ImageAlign.RIGHT
		
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

func _on_Button_pressed(colDef: AceTableColumnDef, dt: Dictionary):
	if !colDef.columnCallable.is_null():
		colDef.columnCallable.call(colDef, dt)
		pressed.emit()
	else:
		AceLog.printLog(["AceTableWarning - Column [%s]: button was pressed but its Callable is null. Check column definition and errors in logs" % [colDef.columnId]], AceLog.LOG_LEVEL.WARN)

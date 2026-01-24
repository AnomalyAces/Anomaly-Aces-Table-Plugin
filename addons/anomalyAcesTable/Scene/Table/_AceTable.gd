@tool
class_name _AceTable extends VBoxContainer

#Scenes and Resources
const _row_scene: Resource = preload("res://addons/anomalyAcesTable/Scene/Row/_AceTableRow.tscn")
const _table_scene: Resource = preload("res://addons/anomalyAcesTable/Scene/Table/_AceTable.tscn")
const _ace_table_button_scene: Resource = preload("res://addons/anomalyAcesTable/Scene/Button/_AceTableButton.tscn")
const _ace_table_button_checkbox_scene: Resource = preload("res://addons/anomalyAcesTable/Scene/Button/ButtonTypes/AceTableButtonCheckbox/_AceTableButtonCheckbox.tscn")
const _default_sort_asc_icon: Resource = preload("res://addons/anomalyAcesTable/Icons/AceTableSortAsc.svg")
const _default_sort_desc_icon: Resource = preload("res://addons/anomalyAcesTable/Icons/AceTableSortDesc.svg")


#Table Parts
var _headerPanel: PanelContainer
var _headerCellContainer: HBoxContainer
var _rowPanel: PanelContainer
var _rowContainer: VBoxContainer 
var _sorter: _AceTableSorter = _AceTableSorter.new()
var _table_data: Array[Dictionary]
var _sorted_table_data: Array[Dictionary]

var plugin: AceTable
var config: _AceTableConfig



#constructor
func _init(plg: AceTable, cfg: _AceTableConfig):
	if(plg == null || cfg == null):
		return
	
	plugin = plg
	config = cfg
	
	plugin.add_child(_table_scene.instantiate())
	
	#Column Config
	## Header Background
	_headerPanel = plugin.get_node("Table/HeaderPanel")
	_headerPanel.set_theme(plugin.header_theme)
	## Header Cells
	_headerCellContainer = plugin.get_node("Table/HeaderPanel/MarginContainer/HeaderCellContainer")
	_headerCellContainer.add_theme_constant_override("separation", plugin.cell_separation)
	
	#Row Config
	#Theme Row Background
	_rowPanel = plugin.get_node("Table/RowPanel")
	_rowPanel.set_theme(plugin.row_theme)
	#Row Container
	_rowContainer = plugin.get_node("Table/RowPanel/MarginContainer/ScrollContainer/RowContainer")
	_rowContainer.add_theme_constant_override("separation", plugin.cell_separation)
	
	_createColumnHeaders()
	

func set_data(dataArr:Array):
	_reset_table_data()
	for dataIdx in dataArr.size():
		var rowScene = _row_scene.instantiate()
		rowScene.name = "Row"+str(dataIdx)
		_rowContainer.add_child(rowScene)
		# Set the row_id for tracking
		dataArr[dataIdx]["row_id"]= dataIdx
		var row = _AceTableRow.new(plugin, config, rowScene, dataArr[dataIdx])
		row.row_selected.connect(_on_row_selected)
		_table_data.append(row.data)

	_sorted_table_data = _table_data.duplicate()

func get_rows() -> Array[Dictionary]:
	return _table_data.duplicate()

func get_sorted_rows() -> Array[Dictionary]:
	return _sorted_table_data.duplicate()

func _createColumnHeaders():
	var cell: _AceTableCell = _AceTableCell.new()
	#add columns to 
	for colDef in config.columnDefs:
		var node_header: Control
		
		if colDef.columnSort:
			node_header = _ace_table_button_scene.instantiate() as _AceTableButton
			AceLog.printLog(["Processing button settings for ColDef [%s]" % [colDef]], AceLog.LOG_LEVEL.DEBUG)
			node_header.colDef = colDef.clone()
			node_header.colDef.columnButtonType = AceTableConstants.ButtonType.HEADER
			# node_header._button_text_alignment = AceTableConstants.Align.CENTER
			# node_header.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			# node_header.expand_icon = true
			# node_header.add_theme_constant_override("icon_max_width", 20)
			(node_header as Button).pressed.connect(_on_column_header_pressed_ascending.bind(node_header, colDef.columnId))
		else:
			if colDef.columnType == AceTableConstants.ColumnType.SELECTION && colDef.columnHasSelectAll:
				node_header = _ace_table_button_checkbox_scene.instantiate() as _AceTableButtonCheckbox
				node_header.colDef = colDef.clone()
				node_header.colDef.columnButtonType = AceTableConstants.ButtonType.HEADER
				node_header.header_selected.connect(_on_row_header_selected)
			else:
				node_header = Label.new()
				node_header.horizontal_alignment = AceTableConstants.Align.CENTER
				node_header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				node_header.text = colDef.columnName
		
		# node_header.text = colDef.columnName
		node_header.name = colDef.columnId
		node_header.size_flags_horizontal = SIZE_EXPAND_FILL
		# node_header.size_flags_vertical = SIZE_EXPAND_FILL
		
		node_header.set_theme(plugin.header_cell_theme)
		_headerCellContainer.add_child(cell.compose_cell(plugin.header_cell_theme, node_header))

func _on_column_header_pressed_ascending(node_header: _AceTableButton, col_key: String):
	_sorter.sort_row_by_column(self, col_key, AceTableConstants.ColumnSort.SORT_ASCENDING)
	_update_sort_buttons(col_key, AceTableConstants.ColumnSort.SORT_ASCENDING)
	
	node_header.disconnect("pressed", _on_column_header_pressed_ascending)
	node_header.connect("pressed", _on_column_header_pressed_descending.bind(node_header, col_key))

func _on_column_header_pressed_descending(node_header: _AceTableButton, col_key: String):
	_sorter.sort_row_by_column(self, col_key, AceTableConstants.ColumnSort.SORT_DESCENDING)
	_update_sort_buttons(col_key, AceTableConstants.ColumnSort.SORT_DESCENDING)
	
	node_header.disconnect("pressed", _on_column_header_pressed_descending)
	node_header.connect("pressed", _on_column_header_pressed_none.bind(node_header, col_key))

func _on_column_header_pressed_none(node_header: _AceTableButton, col_key: String):
	_sorter.sort_row_by_column(self, col_key, AceTableConstants.ColumnSort.NONE)
	_update_sort_buttons(col_key, AceTableConstants.ColumnSort.NONE)
	
	node_header.disconnect("pressed", _on_column_header_pressed_none)
	node_header.connect("pressed", _on_column_header_pressed_ascending.bind(node_header, col_key))

func _update_sort_buttons(sort_col: String, sort_mode: AceTableConstants.ColumnSort):
	var colDef: AceTableColumnDef = AceArrayUtil.findFirst(config.columnDefs, func(cDef:AceTableColumnDef): return cDef.columnId == sort_col)
	for header in _headerCellContainer.get_children():
		var header_node = header.get_node("%sMC/%s" % [header.name.replace("PC", ""), header.name.replace("PC", "")])
		if header_node is _AceTableButton:
			header_node.custom_minimum_size = colDef.columnImageSize if colDef.columnImageSize else Vector2i(64,64)
			if colDef.columnId == header_node.name:
				match sort_mode:
					AceTableConstants.ColumnSort.SORT_ASCENDING:
						var resource: Resource = colDef.columnSortButton.ascending if colDef.columnSortButton else _default_sort_asc_icon
						header_node.texture_rect.texture = resource
						header_node.is_right_icon = true
						header_node.texture_rect.visible = true
					AceTableConstants.ColumnSort.SORT_DESCENDING:
						var resource: Resource = colDef.columnSortButton.descending if colDef.columnSortButton else _default_sort_desc_icon
						header_node.texture_rect.texture = resource
						header_node.is_right_icon = true
						header_node.texture_rect.visible = true
					AceTableConstants.ColumnSort.NONE:
						header_node.texture_rect.visible = false
			else:
				header_node.set_button_icon(null)

func _set_sorted_data(dataArr:Array):
	_reset_sorted_table_data()
	for dataIdx in dataArr.size():
		var rowScene = _row_scene.instantiate()
		rowScene.name = "Row"+str(dataIdx)
		_rowContainer.add_child(rowScene)
		var row = _AceTableRow.new(plugin, config, rowScene, dataArr[dataIdx])
		_sorted_table_data.append(row.data)


func _reset_table_data():
	# Clear existing data
	_table_data.clear()
	_clear_rows()

func _reset_sorted_table_data():
	# Clear existing sorted data
	_sorted_table_data.clear()
	_clear_rows()

	
func _clear_rows():
	#Clear existing row nodes
	### probably not the most effcient way to do this but it will be accurate
	#Remove all children
	for n in _rowContainer.get_children():
		_rowContainer.remove_child(n)


#Signal Handlers
func _on_row_selected(row_data: Dictionary) -> void:
	AceLog.printLog(["_AceTable: Row selected with data [%s]." % [row_data]], AceLog.LOG_LEVEL.DEBUG)
	AceLog.printLog(["_AceTable: Current table data", _table_data], AceLog.LOG_LEVEL.DEBUG)

func _on_row_header_selected(is_toggled: bool) -> void:
	AceLog.printLog(["_AceTable: Header selected with value %s." % [is_toggled]], AceLog.LOG_LEVEL.DEBUG)

	# Grab array as type _AceTableRow for better type handling
	for row in _rowContainer.get_children():
		AceLog.printLog(["_AceTable: Processing row %s for selection update." % [row]], AceLog.LOG_LEVEL.DEBUG)
		if row is _AceTableRow:
			AceLog.printLog(["_AceTable: Updating row %s selection state to %s" % [row, is_toggled]], AceLog.LOG_LEVEL.DEBUG)
			row._table_update_selection(is_toggled)
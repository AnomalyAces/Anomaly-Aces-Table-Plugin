@tool
class_name _AceTable extends VBoxContainer

#Scenes
const _row_scene = preload("res://addons/anomalyAcesTable/Scene/Row/_AceTableRow.tscn")
const _table_scene = preload("res://addons/anomalyAcesTable/Scene/Table/_AceTable.tscn")
const _ace_table_button_scene = preload("res://addons/anomalyAcesTable/Scene/Button/_AceTableButton.tscn")


#Table Parts
var _headerPanel: PanelContainer
var _headerCellContainer: HBoxContainer
var _rowPanel: PanelContainer
var _rowContainer: VBoxContainer 
var _sorter: _AceTableSorter = _AceTableSorter.new()
var _table_data: Array[Dictionary]

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
	_table_data.clear()
	for dataIdx in dataArr.size():
		var rowScene = _row_scene.instantiate()
		rowScene.name = "Row"+str(dataIdx)
		_rowContainer.add_child(rowScene)
		var row = _AceTableRow.new(plugin, config, rowScene, dataArr[dataIdx])
		_table_data.append(row.data)

func get_rows() -> Array[Dictionary]:
	return _table_data.duplicate()

func _createColumnHeaders():
	var cell: _AceTableCell = _AceTableCell.new()
	#add columns to 
	for colDef in config.columnDefs:
		var node_header: Control
		
		if colDef.columnSort:
			node_header = _ace_table_button_scene.instantiate()
			node_header._button_text = colDef.columnName
			node_header.name = colDef.columnName
			node_header._button_text_alignment = AceTableConstants.Align.CENTER
			# node_header.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			# node_header.expand_icon = true
			# node_header.add_theme_constant_override("icon_max_width", 20)
			(node_header as Button).connect("pressed", _on_column_header_pressed_ascending.bind(node_header, colDef.columnId))
		else:
			node_header = Label.new()
			node_header.horizontal_alignment = AceTableConstants.Align.CENTER
			node_header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			node_header.text = colDef.columnName
		
		# node_header.text = colDef.columnName
		node_header.name = colDef.columnId
		node_header.size_flags_horizontal = SIZE_EXPAND_FILL
		node_header.size_flags_vertical = SIZE_EXPAND_FILL
		
		node_header.set_theme(plugin.header_cell_theme)
		_headerCellContainer.add_child(cell.compose_cell(plugin.header_cell_theme, node_header))

func _on_column_header_pressed_ascending(node_header, col_key):
	_sorter.sort_row_by_column(self, col_key, AceTableConstants.ColumnSort.SORT_ASCENDING)
	_update_sort_buttons(col_key, AceTableConstants.ColumnSort.SORT_ASCENDING)
	
	node_header.disconnect("pressed", _on_column_header_pressed_ascending)
	node_header.connect("pressed", _on_column_header_pressed_descending.bind(node_header, col_key))

func _on_column_header_pressed_descending(node_header, col_key):
	_sorter.sort_row_by_column(self, col_key, AceTableConstants.ColumnSort.SORT_DESCENDING)
	_update_sort_buttons(col_key, AceTableConstants.ColumnSort.SORT_DESCENDING)
	
	node_header.disconnect("pressed", _on_column_header_pressed_descending)
	node_header.connect("pressed", _on_column_header_pressed_ascending.bind(node_header, col_key))

func _update_sort_buttons(sort_col: String, sort_mode: AceTableConstants.ColumnSort):
	var colDef: AceTableColumnDef = AceArrayUtil.findFirst(config.columnDefs, func(colDef:AceTableColumnDef): return colDef.columnId == sort_col)
	for header in _headerCellContainer.get_children():
		var header_node = header.get_node("%sMC/%s" % [header.name.replace("PC", ""), header.name.replace("PC", "")])
		if header_node is _AceTableButton:
			if colDef.columnId == header_node.name:
				match sort_mode:
					AceTableConstants.ColumnSort.SORT_ASCENDING:
						var resource: Resource = load(colDef.columnSortButton.ascending) if colDef.columnSortButton else load("res://addons/anomalyAcesTable/Icons/AceTableSortAsc.svg")
						header_node.right_button_icon.texture = resource
						header_node.is_right_icon = true
						# header_node.set_button_icon(resource)
					AceTableConstants.ColumnSort.SORT_DESCENDING:
						var resource: Resource = load(colDef.columnSortButton.descending) if colDef.columnSortButton else load("res://addons/anomalyAcesTable/Icons/AceTableSortDesc.svg")
						header_node.right_button_icon.texture = resource
						header_node.is_right_icon = true
						# header_node.set_button_icon(resource)
			else:
				header_node.set_button_icon(null)

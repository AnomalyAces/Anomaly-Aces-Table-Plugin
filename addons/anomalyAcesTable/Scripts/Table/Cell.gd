const AceTablePlugin = preload("res://addons/anomalyAcesTable/Scripts/ace_table_properties.gd")



func compose_cell(theme: Theme, cell_node: Node) -> Node:
	var cell_container: PanelContainer = PanelContainer.new()
	var cell_margin: MarginContainer = MarginContainer.new()
	
	cell_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell_container.set_theme(theme)
	cell_container.name = cell_node.name + "PC"
	cell_margin.add_child(cell_node)
	cell_margin.name = cell_node.name + "MC"
	cell_container.add_child(cell_margin)
	return cell_container

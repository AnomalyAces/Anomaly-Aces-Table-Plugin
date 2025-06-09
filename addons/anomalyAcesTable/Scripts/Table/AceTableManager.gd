extends Node

const AceTableConfig = preload("res://addons/anomalyAcesTable/Scripts/Table/AceTableConfig.gd")
const AceTablePlugin = preload("res://addons/anomalyAcesTable/Scripts/ace_table_properties.gd")
const Table = preload("res://addons/anomalyAcesTable/Scene/Table/Table.gd")


func createTable(plugin: AceTablePlugin, colDefs: Dictionary, data: Array[Dictionary] = []) -> Table:
	if plugin == null:
		printerr("AceTableManager not initialized, Please call AceTableManager.initialize()")
		return null
	var tblConfig: AceTableConfig = AceTableConfig.new(plugin,colDefs)
	var table: Table = Table.new(plugin, tblConfig)
	
	setTableData(table, data)
		
	return table
	
	
func setTableData(table: Table, data: Array):
	if(data.size() > 0):
		table.set_data(data)

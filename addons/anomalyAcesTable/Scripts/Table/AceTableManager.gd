@tool
class_name AceTableManager extends Node


static func createTable(plugin: AceTable, colDefs: Array[AceTableColumnDef], data: Array[Dictionary] = []) -> _AceTable:
	if plugin == null:
		printerr("AceTableManager not initialized, Please call AceTableManager.initialize()")
		return null
	var tblConfig: _AceTableConfig = _AceTableConfig.new(colDefs)
	var table: _AceTable = _AceTable.new(plugin, tblConfig)
	
	setTableData(table, data)
		
	return table
	
	
static func setTableData(table: _AceTable, data: Array):
	if(data.size() > 0):
		table.set_data(data)

extends Node

const AceTablePlugin = preload("res://addons/anomalyAcesTable/Scripts/ace_table_properties.gd")
const AceTableColumnDef = preload("res://addons/anomalyAcesTable/Scripts/Table/AceTableColumnDef.gd")

#Array of Column Defs to define what Columns Names and Column id of the data entered
var columnDefs: Array[AceTableColumnDef] = []


func _init(plugin: AceTablePlugin, colDefs: Dictionary):
	for colDef in colDefs:
		var columnDef: AceTableColumnDef = AceTableColumnDef.new(colDefs[colDef])
		columnDef.print_errors()
		columnDefs.append(columnDef)

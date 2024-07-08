extends Node

const AceTableColumnDef = preload("res://addons/anomalyAcesTable/Scripts/Table/AceTableColumnDef.gd")

#Array of Column Defs to define what Columns Names and Column id of the data entered
var columnDefs: Array[AceTableColumnDef] = []


func _init(colDefs: Dictionary):
	for colDef in colDefs:
		columnDefs.append(AceTableColumnDef.new(colDefs[colDef]))

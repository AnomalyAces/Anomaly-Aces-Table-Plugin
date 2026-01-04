@tool
class_name AceTableColumnDef extends Node

const INVALID_TYPE: int = -1

class ColumnSortButton:
	var ascending: String
	var descending: String

	func _init(asc: String, desc: String) -> void:
		ascending = asc
		descending = desc

var _validationErrors: PackedStringArray = []

var columnName: String
var columnId: String
var columnType: AceTableConstants.ColumnType = AceTableConstants.ColumnType.NONE
var columnSort: bool = false
var columnSortButton: ColumnSortButton
var columnAlign: AceTableConstants.Align = AceTableConstants.Align.LEFT
var columnImage: String
var columnImageSize: Vector2i = Vector2i(32,32)
var columnImageAlign:AceTableConstants.ImageAlign = AceTableConstants.ImageAlign.LEFT
var columnCallable: Callable
var columnNode: Control


#Check if the columDef is valid
func is_valid() -> bool:
	var warnings: PackedStringArray = []
	if(columnId.is_empty()):
		warnings.append("Column Id is empty")
	if(columnName.is_empty() && columnType != AceTableConstants.ColumnType.SELECTION):
		warnings.append("[%s]: Column Name is empty while Column Type is not 'AceTableConstants.ColumnType.SELECTION'" % columnId)
	if(columnType == AceTableConstants.ColumnType.NONE):
		warnings.append("Column Definition Input invalid")
	if(columnType == AceTableConstants.ColumnType.BUTTON && columnCallable.is_null()):
		warnings.append("[%s]: Column Type is Button but no Callable has been given" % columnId)
	if(columnNode):
		if(!_isValidNode()):
			warnings.append("[%s]: Column Node %s' does not match Column Type %s" % [columnId, columnNode.name, AceTableConstants.ColumnType.keys()[columnType]])
	
	_validationErrors = warnings
	return warnings.is_empty()

func print_errors():
	for error in _validationErrors:
		AceLog.printLog(["AceTableError - "+error], AceLog.LOG_LEVEL.ERROR)

func _isValidNode() -> bool:
	match columnType:
		AceTableConstants.ColumnType.LABEL:
			return columnNode is Label
		AceTableConstants.ColumnType.BUTTON:
			return columnNode is BaseButton
		AceTableConstants.ColumnType.TEXTURE_RECT:
			return columnNode is TextureRect
		AceTableConstants.ColumnType.SELECTION:
			return columnNode is CheckBox
		_:
			AceLog.printLog(["Column Node %s' does not match Column Type %s" % [columnNode.name, AceTableConstants.ColumnType.keys()[columnType]]], AceLog.LOG_LEVEL.ERROR)
			return false

func _to_string() -> String:
	var dict: Dictionary = {
		"columnName": columnName,
		"columnId": columnId,
		"columnType": AceTableConstants.ColumnType.keys()[columnType],
		"columnSort": columnSort,
		"columnAlign": AceTableConstants.Align.keys()[columnAlign],
		"columnImage": columnImage,
		"columnImageSize": columnImageSize,
		"columnImageAlign": AceTableConstants.ImageAlign.keys()[columnImageAlign],
		"columnCallable": str(columnCallable),
		"columnNode": str(columnNode)
	}
	return JSON.stringify(dict)
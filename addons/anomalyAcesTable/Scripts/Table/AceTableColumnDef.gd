extends Node

const INVALID_TYPE: int = -1

#Schemas

var columnDefSchema: z_schema = Z.schema({
	"columnId": Z.string().non_empty(),
	"columnName": Z.string().non_empty(),
	"columnType": Z.zenum(AceTableConstants.ColumnType),
	"columnSort": Z.boolean().nullable(),
	"columnImage": Z.string().non_empty().nullable(),
	"columnCallable": Z.callable().nullable(),
	"columnAlign": Z.zenum(AceTableConstants.Align).nullable(),
	"columnNode": Z.union([Z.label(), Z.base_button(), Z.texture_rect()]).nullable()
})

var columnName: String
var columnId: String
var columnType: int
var columnSort: bool = false
var columnAlign: int
var columnImage: String
var columnFunc: Callable
var columnNode: Control

#constructor
func _init(colDef: Dictionary = {}):
	var val_res: ZodotResult = _isValidColDef(colDef)
	if(val_res.ok()):
		columnId = colDef.columnId
		columnName = colDef.columnName
		
		if(colDef.columnType > 0):
			columnType = colDef.columnType
		else:
			columnType = AceTableConstants.ColumnType.LABEL
		
		if(colDef.has("columnSort")):
			columnSort = colDef.columnSort
		if(colDef.has("columnImage") && !colDef.columnImage.is_empty()):
			columnImage = colDef.columnImage
		if(colDef.has("columnFunc") && colDef.columnFunc != null):
			columnFunc = colDef.columnFunc
		if(colDef.has("columnAlign")):
			columnAlign = colDef.columnAlign
		else:
			columnAlign = 0
		if(_isValidNode(colDef)):
			columnNode = colDef.columnNode
			

	else:
		columnType = INVALID_TYPE
		push_error("Column Def Error: %s " % [val_res.error])

#Check if the columDef is valid
func isValid() -> bool:
	var isValid: bool = true
	if(columnId.is_empty()):
		isValid = false
	if(columnName.is_empty()):
		isValid = false
	if(columnType < 0):
		isValid = false
	if(columnType == AceTableConstants.ColumnType.BUTTON && columnFunc == null):
		isValid = false
	return isValid

#Check if the columDef input is valid
func _isValidColDef(colDef: Dictionary) -> ZodotResult:
	return columnDefSchema.parse(colDef)

func _isValidNode(colDef: Dictionary) -> bool:
	if colDef.has("columnNode"):
		match colDef.columnType:
			AceTableConstants.ColumnType.LABEL:
				return colDef.columnNode is Label
			AceTableConstants.ColumnType.BUTTON:
				return colDef.columnNode is BaseButton
			AceTableConstants.ColumnType.TEXTURE_RECT:
				return colDef.columnNode is TextureRect
			_:
				push_error("Column Node %s' does not match Column Column Type %s... skipping assignment" % [colDef.columnNode.name, colDef.columnType])
				return false
	else:
		return false

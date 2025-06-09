extends Node

const INVALID_TYPE: int = -1

var _validationErrors: PackedStringArray = []

#Schemas
var columnSortButtonSchema: z_schema = Z.schema({
	"asc": Z.string().non_empty(),
	"desc": Z.string().non_empty(),
})

var columnDefSchema: z_schema = Z.schema({
	"columnId": Z.string().non_empty(),
	"columnName": Z.string().non_empty(),
	"columnType": Z.zenum(AceTableConstants.ColumnType),
	"columnSort": Z.boolean().nullable(),
	"columnSortButtons": Z.dictionary(columnSortButtonSchema).non_empty().nullable(),
	"columnImage": Z.string().non_empty().nullable(),
	"columnCallable": Z.callable().nullable(),
	"columnAlign": Z.zenum(AceTableConstants.Align).nullable(),
	"columnNode": Z.union([Z.custom().type(Label), Z.custom().type(BaseButton), Z.custom().type(TextureRect)]).nullable()
})

var columnName: String
var columnId: String
var columnType: int
var columnSort: bool = false
var columnSortButtons: Dictionary
var columnAlign: int = -1
var columnImage: String
var columnCallable: Callable
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
		if(colDef.has("columnSortButtons")):
			columnSortButtons = colDef.columnSortButtons
		if(colDef.has("columnImage") && !colDef.columnImage.is_empty()):
			columnImage = colDef.columnImage
		if(colDef.has("columnCallable") && colDef.columnCallable != null):
			columnCallable = colDef.columnCallable
		if(colDef.has("columnAlign")):
			columnAlign = colDef.columnAlign
		else:
			columnAlign = 0
		if(_isValidNode(colDef)):
			columnNode = colDef.columnNode
			

	else:
		columnType = INVALID_TYPE
		push_error("Column Def Error: %s " % [val_res.error])
		
	#Gather validation Errors
	_validationErrors = is_valid()

#Check if the columDef is valid
func is_valid() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if(columnId.is_empty()):
		warnings.append("Column Id is empty")
	if(columnName.is_empty()):
		warnings.append("[%s]: Column Name is empty" % columnId)
	if(columnType < 0):
		warnings.append("Column Definition Input invalid")
	if(columnType == AceTableConstants.ColumnType.BUTTON && columnCallable.is_null()):
		warnings.append("[%s]: Column Type is Button but no Callable has been given" % columnId)
	
	return warnings

func print_errors():
	for error in _validationErrors:
		push_error("AceTableError - "+error)

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

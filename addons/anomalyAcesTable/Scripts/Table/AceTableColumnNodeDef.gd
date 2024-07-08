extends Node

#Schemas
var columnNodeDefSchema: z_schema = Z.schema({
	"label": Z.label().nullable(),
	"button": Z.base_button().nullable(),
	"textureRect": Z.texture_rect().nullable()
})

var label: Label
var button: BaseButton
var textureRect: TextureRect

#constructor
func _init(colNodeDefs: Dictionary):
	var val_res: ZodotResult = _validateColNodeDef(colNodeDefs)
	if(val_res.ok()):
		label = null if not colNodeDefs.has("label") else colNodeDefs["label"]
		button = null if not colNodeDefs.has("button") else colNodeDefs["button"]
		textureRect = null if not colNodeDefs.has("textureRect") else colNodeDefs["textureRect"]
	else:
		push_error("Column Def Error: %s " % [val_res.error])


func _validateColNodeDef(colNodeDefs: Dictionary) -> ZodotResult:
	return columnNodeDefSchema.parse(colNodeDefs)
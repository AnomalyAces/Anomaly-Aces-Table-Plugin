#Added by AnomalyAces
#Designed to validate Labels
#TODO: Commit to Zodot Repository
class_name z_label extends Zodot

func _valid_type(value: Variant) -> bool:
	return value is Label

func parse(value: Variant, field: String = "") -> ZodotResult:
	if _coerce and typeof(value) == TYPE_STRING:
		value = str_to_var(value)
		
	if _nullable and value == null:
		return ZodotResult.good(value)
	
	if not _valid_type(value):
		return ZodotResult.type_error(field)
		
	return ZodotResult.good(value)

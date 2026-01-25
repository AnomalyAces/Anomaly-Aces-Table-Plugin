@tool
class_name _AceTableText extends HBoxContainer


var texture_rect: TextureRect
var label: Label
var colDef: AceTableColumnDef
var data: Dictionary
var type: AceTableConstants.TextType = AceTableConstants.TextType.TEXT:
	set(t_type):
		type = t_type
		match type:
			AceTableConstants.TextType.ICON:
				label.visible = false
				texture_rect.visible = true
			AceTableConstants.TextType.TEXT:
				texture_rect.visible = false
				label.visible = true
			AceTableConstants.TextType.COMBO:
				texture_rect.visible = true
				label.visible = true
			AceTableConstants.TextType.HEADER:
				texture_rect.visible = false
				label.visible = true

var is_right_icon: bool = false:
	set(is_right):
		is_right_icon = is_right
		if texture_rect != null:
			if is_right_icon:
				move_child(texture_rect, 1)
			else:
				move_child(texture_rect, 0)


func _ready() -> void:
	texture_rect = $TextureRect
	label = $Label

	_apply_text_settings()


func _apply_text_settings():
	AceLog.printLog(["_AceTableText: Applying text settings for ColDef [%s]" % [colDef]], AceLog.LOG_LEVEL.DEBUG)

	if colDef == null:
		return
	
	name = colDef.columnId

	label.horizontal_alignment = int(colDef.columnAlign) as HorizontalAlignment

	size_flags_horizontal = SIZE_EXPAND_FILL
	type = colDef.columnTextType
	is_right_icon = colDef.columnImageAlign == AceTableConstants.ImageAlign.RIGHT
	if colDef.columnTextType == AceTableConstants.TextType.HEADER:
		label.text = colDef.columnName
	else:
		label.text = data[colDef.columnId]

	_set_normal_colors()

func _update_shader(textureRect: TextureRect, color: Color):
	if colDef.columnTextIconUpdateWithState:
		textureRect.set_instance_shader_parameter("instance_color", color)

func _set_normal_colors():

	label.add_theme_color_override("font_color", get_theme_color("font_color", "Button"))
	_update_shader(texture_rect,  get_theme_color("icon_normal_color", "Button"))

func _set_active_colors():
	label.add_theme_color_override("font_color", get_theme_color("font_pressed_color", "Button"))
	_update_shader(texture_rect,  get_theme_color("icon_pressed_color", "Button"))

func _on_mouse_exited() -> void:
	_set_normal_colors()


func _on_mouse_entered() -> void:
	_set_active_colors()


func _on_focus_exited() -> void:
	_set_normal_colors()


func _on_focus_entered() -> void:
	_set_active_colors()

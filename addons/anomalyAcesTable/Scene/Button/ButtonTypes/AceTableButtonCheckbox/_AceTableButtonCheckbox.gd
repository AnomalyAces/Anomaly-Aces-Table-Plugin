@tool
class_name _AceTableButtonCheckbox extends TextureButton

var colDef: AceTableColumnDef
var data: Dictionary

var _prev_disabled: bool = false

func _ready() -> void:

	_apply_button_settings()


func _enter_tree() -> void:
	_prev_disabled = disabled
	set_process(true)

func _process(_delta: float) -> void:
	_update_disabled_state()

func _apply_button_settings():
	AceLog.printLog(["_AceTableButtonCheckbox: Applying button settings for ColDef [%s]" % [colDef]], AceLog.LOG_LEVEL.DEBUG)
	name = colDef.columnId
	size_flags_horizontal = SIZE_EXPAND_FILL
	toggled.connect(_on_toggled)


func _update_disabled_state():
	if disabled == _prev_disabled:
		return
	_prev_disabled = disabled
	if disabled:
		_set_disabled_colors()
	else:
		_set_normal_colors()


func _update_shader(color: Color):
	set_instance_shader_parameter("instance_color", color)

func _set_normal_colors():

	if disabled:
		return

	_update_shader(get_theme_color("icon_normal_color", "Button"))

func _set_disabled_colors():
	_update_shader(get_theme_color("icon_disabled_color", "Button"))

func _set_active_colors():
	if disabled:
		return

	_update_shader(get_theme_color("icon_pressed_color", "Button"))


func _on_toggled(is_toggled: bool) -> void:
	if is_toggled:
		_set_active_colors()
	else:
		_set_normal_colors()

	
@tool
class_name _AceTableButton extends Button

var _button_icon: Texture2D
var _button_icon_size: Vector2i
var _button_text: String
var _button_text_alignment: AceTableConstants.Align

var left_container: HBoxContainer
var left_button_icon: TextureRect
var left_button_text: Label

var right_container: HBoxContainer
var right_button_icon: TextureRect
var right_button_text: Label

var is_right_icon: bool = false:
	set(is_right):
		is_right_icon = is_right
		if left_container:
			left_container.visible = !is_right_icon
		if right_container:
			right_container.visible = is_right_icon





func _init() -> void:
	left_button_icon = TextureRect.new()
	left_button_text = Label.new()

	right_button_icon = TextureRect.new()
	right_button_text =Label.new()

func _ready() -> void:
	left_container = $MarginContainer/IconLeft
	left_button_icon = $MarginContainer/IconLeft/TextureRect
	left_button_text = $MarginContainer/IconLeft/Label

	right_container = $MarginContainer/IconRight
	right_button_icon = $MarginContainer/IconRight/TextureRect
	right_button_text = $MarginContainer/IconRight/Label
	
	left_button_icon.texture = _button_icon
	left_button_icon.size = _button_icon_size
	left_button_text.text = _button_text
	left_button_text.horizontal_alignment = int(_button_text_alignment)

	right_button_icon.texture = _button_icon
	right_button_icon.size = _button_icon_size
	right_button_text.text = _button_text
	right_button_text.horizontal_alignment = int(_button_text_alignment)

	left_container.visible = !is_right_icon
	right_container.visible = is_right_icon


func set_disabled(value: bool):
	# Call the parent's setter to ensure the disabled state is actually applied
	super.set_disabled(value)

	if value == true:
		_set_disabled_colors()
	else:
		_set_normal_colors()

func _update_shader(textureRect: TextureRect, color: Color):
	textureRect.set_instance_shader_parameter("instance_color", color)

func _set_normal_colors():

	if disabled:
		return

	left_button_text.add_theme_color_override("font_color", get_theme_color("font_color", "Button"))
	right_button_text.add_theme_color_override("font_color", get_theme_color("font_color", "Button"))

	_update_shader(left_button_icon,  get_theme_color("font_color", "Button"))
	_update_shader(right_button_icon,  get_theme_color("font_color", "Button"))

func _set_disabled_colors():
	left_button_text.add_theme_color_override("font_color", get_theme_color("font_disabled_color", "Button"))
	right_button_text.add_theme_color_override("font_color", get_theme_color("font_disabled_color", "Button"))

	_update_shader(left_button_icon,  get_theme_color("font_disabled_color", "Button"))
	_update_shader(right_button_icon,  get_theme_color("font_disabled_color", "Button"))

func _set_active_colors():
	if disabled:
			return

	left_button_text.add_theme_color_override("font_color", get_theme_color("font_pressed_color", "Button"))
	right_button_text.add_theme_color_override("font_color", get_theme_color("font_pressed_color", "Button"))

	_update_shader(left_button_icon,  get_theme_color("font_pressed_color", "Button"))
	_update_shader(right_button_icon,  get_theme_color("font_pressed_color", "Button"))


func _on_button_up() -> void:
	_set_normal_colors()


func _on_pressed() -> void:
	_set_active_colors()


func _on_icon_right_mouse_exited() -> void:
	_set_normal_colors()


func _on_icon_right_mouse_entered() -> void:
	_set_active_colors()


func _on_icon_right_focus_exited() -> void:
	_set_normal_colors()


func _on_icon_right_focus_entered() -> void:
	_set_active_colors()


func _on_icon_left_focus_exited() -> void:
	_set_normal_colors()


func _on_icon_left_focus_entered() -> void:
	_set_active_colors()


func _on_icon_left_mouse_exited() -> void:
	_set_normal_colors()

func _on_icon_left_mouse_entered() -> void:
	_set_active_colors()

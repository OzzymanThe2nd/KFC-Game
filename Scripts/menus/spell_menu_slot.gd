extends Panel
var mouse_inside : bool = false
var right_click_menu = null
var rmb_menu_has_mouse = false
@export var select_slot : bool = true
@export var holding : String
@onready var tooltip_setting = preload("res://menu_font.tres")
var locked : bool = false
var locked_image = "res://textures/grass32.png"
var spell_menu

func update(spell_in_slot):
	%Sprite2D.texture = load(spell_in_slot)
	if holding != "":
		tooltip_text = holding.capitalize()
		_make_custom_tooltip(tooltip_text)

func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = for_text
	label.label_settings = tooltip_setting
	return label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	spell_menu = get_parent()
	for i in 2:
		spell_menu = spell_menu.get_parent()

func _on_mouse_entered() -> void:
	mouse_inside = true

func _on_mouse_exited() -> void:
	mouse_inside = false

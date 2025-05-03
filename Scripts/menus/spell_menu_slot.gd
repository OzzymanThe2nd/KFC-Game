extends Panel
var mouse_inside : bool = false
var right_click_menu = null
var rmb_menu_has_mouse = false
@export var select_slot : bool = true
@export var holding : String
@onready var tooltip_setting = preload("res://menu_font.tres")
@onready var right_click_menu_load = preload("res://Scenes/Menus/spell_menu_right_click.tscn")
var locked : bool = false
var locked_image = "res://textures/grass32.png"
var spell_menu

func update(spell_in_slot):
	%Sprite2D.texture = load(spell_in_slot)
	if holding != "" and Playerstatus.unlocked_spells.has(holding):
		tooltip_text = holding.capitalize()
		_make_custom_tooltip(tooltip_text)

func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = for_text
	label.label_settings = tooltip_setting
	return label

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_pressed("right_click"):
			if right_click_menu != null:
				right_click_menu.queue_free()
			if mouse_inside == true and locked == false:
				right_click_menu = right_click_menu_load.instantiate()
				right_click_menu.spell_menu = spell_menu
				right_click_menu.holding = holding
				add_child(right_click_menu)
				right_click_menu.mouse_entered.connect(context_mouse_entered)
				right_click_menu.mouse_exited.connect(context_mouse_exited)
				right_click_menu.position = get_viewport().get_mouse_position()
				rmb_menu_has_mouse = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	spell_menu = get_parent()
	for i in 2:
		spell_menu = spell_menu.get_parent()

func context_mouse_entered():
	rmb_menu_has_mouse = true
	
func context_mouse_exited():
	rmb_menu_has_mouse = false
	for i in 6:
		await get_tree().process_frame
	if right_click_menu != null and mouse_inside == false:
		right_click_menu.queue_free()

func _on_mouse_entered() -> void:
	mouse_inside = true

func _on_mouse_exited() -> void:
	mouse_inside = false
	for i in 6:
		await get_tree().process_frame
	if right_click_menu != null and rmb_menu_has_mouse == false:
		right_click_menu.queue_free()

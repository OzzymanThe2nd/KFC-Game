extends Panel
var mouse_inside : bool = false
var right_click_menu = null
var rmb_menu_has_mouse = false
@export var select_slot : bool = true
@export var holding : String
var locked : bool = false
var locked_image = "res://textures/grass32.png"

func update(spell_in_slot):
	%Sprite2D.texture = load(spell_in_slot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	mouse_inside = true

func _on_mouse_exited() -> void:
	mouse_inside = false

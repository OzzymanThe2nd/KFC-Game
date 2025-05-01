extends Panel
var mouse_inside : bool = false
var right_click_menu = null
var rmb_menu_has_mouse = false

func update(spell_in_slot):
	%Sprite2D.texture = load(spell_in_slot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

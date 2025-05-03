extends Panel
var spell_menu
var holding : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_equip_1_pressed() -> void:
	Playerstatus.equipped_spells[0] = holding
	spell_menu.update_slots()
	queue_free()


func _on_equip_2_pressed() -> void:
	Playerstatus.equipped_spells[1] = holding
	spell_menu.update_slots()
	queue_free()

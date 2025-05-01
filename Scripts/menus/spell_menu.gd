extends Control
var active : bool = true
var player
@onready var select_slots = $"Selection/Select Slots".get_children()
#Formatting: sprite path, cost, cast speed, description
var spelltable_dict = {
	"fireball" : ["res://icon.svg", 8, 0.3, "A small fireball, dealing minimal damage for modeste amounts of spirit."],
	"heal" : ["res://icon.svg", 12, 0.6, "A basic healing spell. Takes a lot of spirit for minimal results, but beats nothing."]
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Playerstatus.keepplayer
	open()


func open():
	player.hud_pixelate(false)
	player.show_hud(false)
	player.show_interact_prompt(false)
	get_tree().paused = true
	update_slots()
	visible = true
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close():
	player.hud_pixelate(true)
	player.show_hud(true)
	player.show_interact_prompt(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()

func update_slots():
	var slots = %"Equip Slots".get_children()
	slots[0].update(spelltable_dict[Playerstatus.equipped_spells[0]][0])
	slots[1].update(spelltable_dict[Playerstatus.equipped_spells[1]][0])
	for i in select_slots:
		if i.holding != "":
			i.update((spelltable_dict[i.holding])[0])
		else:
			i.locked = true
			i.update(i.locked_image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func info_update(spell):
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and get_tree().paused == true and active == true:
			await get_tree().process_frame
			close()
	if event is InputEventMouseButton:
		if Input.is_action_pressed("left_click"):
			for i in select_slots:
				if i.mouse_inside and i.locked == false:
					info_update(i.holding)

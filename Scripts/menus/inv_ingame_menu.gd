extends Control

var player
var inventory: inv
@onready var slots : Array = $"Full Inventory/GridContainer".get_children()
var equipment: inv
@onready var equipment_slots : Array = $Equipment/GridContainer.get_children()
var is_open = false
var stored_item
var stored_slot
var swap_slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent()
	for i in 2:
		player = player.get_parent()
	for i in 3:
		await get_tree().process_frame
	inventory = player.inventory
	equipment = player.equipment
	inventory.update.connect(update_slots)
	close(false)
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("inventory"):
			if is_open == true:
				close()
			elif is_open == false:
				open()
		if Input.is_action_just_pressed("pause") and get_tree().paused == true and is_open:
			await get_tree().process_frame
			close()
	if event is InputEventMouseButton:
		if Input.is_action_pressed("left_click"):
			var run = 0
			for i in slots:
				if i.mouse_inside:
					stored_item = i.slot_keep
					stored_slot = run
				run += 1
		if Input.is_action_just_released("left_click"):
			var run = 0
			for i in slots:
				if i.mouse_inside:
					swap_slot = run
				run += 1
			if stored_slot and swap_slot and stored_slot != swap_slot:
				inventory.slots[stored_slot] = inventory.slots[swap_slot].duplicate()
				inventory.slots[swap_slot] = stored_item
			swap_slot = null
			stored_item = null
			stored_slot = null
			update_slots()

func play_equip_sound():
	$EquipSound.play()

func play_unequip_sound():
	$UnequipSound.play()

func update_slots():
	for i in range(min(inventory.slots.size(),slots.size())):
		slots[i].update(inventory.slots[i])
	for i in range(min(equipment.slots.size(),equipment_slots.size())):
		equipment_slots[i].update(equipment.slots[i])
	$Equipment/ColorRect/Slash.text = "Slash Protection: %s" % str(Playerstatus.protslash)
	$Equipment/ColorRect/Crush.text = "Crush Protection: %s" % str(Playerstatus.protcrush)
	$Equipment/ColorRect/Stab.text = "Stab Protection: %s" % str(Playerstatus.protstab)
	$Equipment/ColorRect/Damage.text = "Melee Damage: %s" % str(Playerstatus.display_damage)

func open(sound_enable = true):
	if not get_tree().paused == true:
		visible = true
		is_open = true
		update_slots()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = true
		if sound_enable == true:
			$OpenSound.play()

func close(sound_enable = true):
	visible = false
	is_open = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	if sound_enable == true:
		$CloseSound.play()

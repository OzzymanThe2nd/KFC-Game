extends Control

var player
var inventory: inv
@onready var slots : Array = $"ColorRect/Full Inventory/GridContainer".get_children()
var chest: inv
@onready var chest_slots : Array = $ColorRect/Chest/GridContainer.get_children()
var is_open = false
var stored_item
var stored_slot
var stored_slot_in_chest : bool = false
var swap_slot
var swap_chest : bool = false
var inspect_windows = []

# Called when the node enters the scene tree for the first time.
	
func _input(event):
	if is_open == true:
		if event is InputEventKey:
			if Input.is_action_just_pressed("inventory"):
				if is_open == true:
					close()
				#elif is_open == false:
					#open()
			if Input.is_action_just_pressed("pause") and get_tree().paused == true and is_open:
				await get_tree().process_frame
				close()
		if event is InputEventMouseButton:
			if Input.is_action_pressed("left_click"):
				var run = 0
				for i in slots:
					if i.mouse_inside:
						#stored_item = i.slot_keep
						stored_slot = run
						stored_item = inventory.slots[run].duplicate()
					run += 1
				if stored_slot == null:
					run = 0
					for i in chest_slots:
						if i.mouse_inside:
							#stored_item = i.slot_keep
							stored_slot = run
							stored_item = chest.slots[run].duplicate()
							stored_slot_in_chest = true
						run += 1
			if Input.is_action_just_released("left_click"):
				var run = 0
				for i in slots:
					if i.mouse_inside:
						swap_slot = run
					run += 1
				if swap_slot == null:
					run = 0
					for i in chest_slots:
						if i.mouse_inside:
							swap_slot = run
							swap_chest = true
						run += 1
				if stored_slot != null and swap_slot != null and stored_slot != swap_slot and swap_chest == false and stored_slot_in_chest == false:
					if inventory.slots[stored_slot].item == inventory.slots[swap_slot].item:
						inventory.slots[stored_slot].amount += inventory.slots[swap_slot].amount
						inventory.slots[swap_slot].amount = 0
						inventory.slots[swap_slot].item = null
					else:
						inventory.slots[stored_slot] = inventory.slots[swap_slot].duplicate()
						inventory.slots[swap_slot] = stored_item
				elif swap_chest == true and stored_slot != null and swap_slot != null and stored_slot_in_chest == false:
					if inventory.slots[stored_slot].item == chest.slots[swap_slot].item:
						inventory.slots[stored_slot].amount += chest.slots[swap_slot].amount
						chest.slots[swap_slot].amount = 0
						chest.slots[swap_slot].item = null
					else:
						inventory.slots[stored_slot] = chest.slots[swap_slot].duplicate()
						chest.slots[swap_slot] = stored_item
				elif stored_slot_in_chest == true and swap_chest == true and stored_slot != null and swap_slot != null and stored_slot != swap_slot:
					if chest.slots[stored_slot].item == chest.slots[swap_slot].item:
						chest.slots[stored_slot].amount += chest.slots[swap_slot].amount
						chest.slots[swap_slot].amount = 0
						chest.slots[swap_slot].item = null
					else:
						chest.slots[stored_slot] = chest.slots[swap_slot].duplicate()
						chest.slots[swap_slot] = stored_item
				elif swap_chest == false and stored_slot != null and swap_slot != null and stored_slot_in_chest == true:
					if chest.slots[stored_slot].item == inventory.slots[swap_slot].item:
						chest.slots[stored_slot].amount += inventory.slots[swap_slot].amount
						inventory.slots[swap_slot].amount = 0
						inventory.slots[swap_slot].item = null
					else:
						chest.slots[stored_slot] = inventory.slots[swap_slot].duplicate()
						inventory.slots[swap_slot] = stored_item
				swap_slot = null
				stored_item = null
				stored_slot = null
				swap_chest = false
				stored_slot_in_chest = false
				update_slots()

#func play_equip_sound():
	#$EquipSound.play()
#
#func play_unequip_sound():
	#$UnequipSound.play()

func update_slots():
	for i in range(min(inventory.slots.size(),slots.size())):
		slots[i].update(inventory.slots[i])
	for i in range(min(chest.slots.size(),chest_slots.size())):
		chest_slots[i].update(chest.slots[i])

func open(sound_enable = true):
	player = Playerstatus.keepplayer
	player.hud_pixelate(false)
	player.show_hud(false)
	player.show_interact_prompt(false)
	inventory = player.inventory
	chest = Playerstatus.chest_inven
	inventory.update.connect(update_slots)
	if get_tree().paused == false:
		visible = true
		is_open = true
		update_slots()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = true
		#if sound_enable == true:
			#$OpenSound.play()

func close(sound_enable = true):
	visible = false
	is_open = false
	player.hud_pixelate(true)
	player.show_hud(true)
	player.show_interact_prompt(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	#if sound_enable == true:
		#$CloseSound.play()

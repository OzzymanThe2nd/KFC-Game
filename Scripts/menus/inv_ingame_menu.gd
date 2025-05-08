extends Control

var player
var inventory: inv
@onready var slots : Array = $ColorRect/"Full Inventory/GridContainer".get_children()
var equipment: inv
@onready var equipment_slots : Array = $ColorRect/Equipment/GridContainer.get_children()
var is_open = false
var stored_item
var stored_slot
var swap_slot
var current_sound
var inspect_windows = []

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
					#stored_item = i.slot_keep
					stored_slot = run
					stored_item = inventory.slots[run].duplicate()
					if i.slot_keep.item != null:
						current_sound = i.slot_keep.item.soundtype
						play_pick_sound(current_sound)
				run += 1
		if Input.is_action_just_released("left_click"):
			var run = 0
			for i in slots:
				if i.mouse_inside:
					swap_slot = run
				run += 1
			if stored_slot != null and swap_slot != null and stored_slot != swap_slot:
				if inventory.slots[stored_slot].item == inventory.slots[swap_slot].item:
					inventory.slots[stored_slot].amount += inventory.slots[swap_slot].amount
					inventory.slots[swap_slot].amount = 0
					inventory.slots[swap_slot].item = null
				else:
					inventory.slots[stored_slot] = inventory.slots[swap_slot].duplicate()
					inventory.slots[swap_slot] = stored_item
				play_drop_sound(current_sound)
			swap_slot = null
			stored_item = null
			stored_slot = null
			current_sound = null
			update_slots()

func play_equip_sound():
	$EquipSound.play()

func play_drop_sound(type = null):
	if type == "light_armour": $DropSound.stream = load("res://Assets/Sounds/Inventory/LightArmour/LightArmourDrop.wav")
	elif type == "sharp": $DropSound.stream = load("res://Assets/Sounds/Inventory/WeaponSharp/WeaponSharpDrop.wav")
	elif type == "blunt": $DropSound.stream = load("res://Assets/Sounds/Inventory/WeaponBlunt/WeaponBluntDrop.wav")
	else: $DropSound.stream = load("res://Assets/Sounds/Inventory/Generic/GenericDropItem.wav")
	$DropSound.play()

func play_pick_sound(type = null):
	if type == "light_armour": $PickSound.stream = load("res://Assets/Sounds/Inventory/LightArmour/LightArmourPick.wav")
	elif type == "sharp": $PickSound.stream = load("res://Assets/Sounds/Inventory/WeaponSharp/WeaponSharpPick.wav")
	elif type == "blunt": $PickSound.stream = load("res://Assets/Sounds/Inventory/WeaponBlunt/WeaponBluntPick.wav")
	else: $PickSound.stream = load("res://Assets/Sounds/Inventory/Generic/GenericPickItem.wav")
	$PickSound.play()

func play_unequip_sound():
	$UnequipSound.play()

func update_slots():
	for i in range(min(inventory.slots.size(),slots.size())):
		slots[i].update(inventory.slots[i])
		slots[i].item_run = i
	for i in range(min(equipment.slots.size(),equipment_slots.size())):
		equipment_slots[i].update(equipment.slots[i])
	$ColorRect/Equipment/ColorRect/Slash.text = "Slash Protection: %s" % str(Playerstatus.protslash)
	$ColorRect/Equipment/ColorRect/Crush.text = "Crush Protection: %s" % str(Playerstatus.protcrush)
	$ColorRect/Equipment/ColorRect/Stab.text = "Stab Protection: %s" % str(Playerstatus.protstab)
	$ColorRect/Equipment/ColorRect/Damage.text = "Melee Damage: %s" % str(Playerstatus.display_damage)
	$ColorRect/Equipment/ColorRect/Level.text = "Level: %s" % str(Playerstatus.player_level)
	$ColorRect/Equipment/ColorRect/Strength.text = "Strength: %s" % str(Playerstatus.strength)
	$ColorRect/Equipment/ColorRect/Archery.text = "Archery: %s" % str(Playerstatus.archery)
	$ColorRect/Equipment/ColorRect/Magic.text = "Magic: %s" % str(Playerstatus.magic)
	var level_up_threshold = int(100 * (1.25 ** Playerstatus.player_level))
	%XPnum.text = "%s/%s" %[str(Playerstatus.player_experience), str(level_up_threshold)]
	%XP.max_value = level_up_threshold
	%XP.value = Playerstatus.player_experience

func open(sound_enable = true):
	if not get_tree().paused == true:
		for i in inspect_windows:
			if not is_instance_valid(i):
				inspect_windows.erase(i)
			if is_instance_valid(i):
				i.queue_free()
		visible = true
		is_open = true
		update_slots()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		player.show_interact_prompt(false)
		player.show_hud(false)
		get_tree().paused = true
		if sound_enable == true:
			$OpenSound.play()

func close(sound_enable = true):
	for i in inspect_windows:
		if not is_instance_valid(i):
			inspect_windows.erase(i)
		if is_instance_valid(i):
			i.queue_free()
	visible = false
	is_open = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player.get_node("CamNode3D/CamSmooth/PCamera/Interact").is_colliding():
		player.show_interact_prompt(true)
	player.show_hud(true)
	get_tree().paused = false
	if sound_enable == true:
		$CloseSound.play()

extends Panel
var item = null
var player 
var inventory
var inventory_slot
var equipment
var get_player_equipment : bool = false
var get_player : bool = false
var get_inv : bool = false
var inspect_menu_path = "res://Scenes/Menus/inspect_menu.tscn"
var chest : bool = false
var item_run : int
@onready var inspect = $VBoxContainer/Inspect
@onready var equip = $VBoxContainer/Equip
@onready var unequip = $VBoxContainer/Unequip
@onready var use = $VBoxContainer/Use
@onready var label = $VBoxContainer/Label
@onready var drop = $VBoxContainer/Drop
@onready var discard = $VBoxContainer/Discard


func _ready() -> void:
	inventory_slot = get_parent()
	if chest == false:
		if get_player == true:
			player = Playerstatus.keepplayer
		if get_inv == true:
			inventory = get_parent()
			for i in 6:
				inventory = inventory.get_parent()
		if get_player_equipment == true:
			equipment = player.equipment
	else:
		if get_player == true:
			player = Playerstatus.keepplayer
		if get_inv == true:
			inventory = get_parent()
			for i in 6:
				inventory = inventory.get_parent()
		if get_player_equipment == true:
			equipment = player.equipment

func text_update():
	clear_all()
	inspect.visible = true
	inspect.disabled = false
	if not inventory_slot.is_equipment_slot:
		discard.visible = true
		discard.disabled = false
		drop.visible = true
		drop.disabled = false
	if item.type == "usable" and player and inventory and not inventory_slot.is_equipment_slot:
		use.disabled = false
		use.visible = true
	elif item.type == "key" and player and inventory and not inventory_slot.is_equipment_slot:
		use.disabled = true
		use.visible = false
		discard.visible = false
		discard.disabled = true
		drop.visible = false
		drop.disabled = true
	elif not check_if_helmet():
		if not check_if_chest():
			if not check_if_gloves():
				if not check_if_legs():
					if not check_if_weapon():
						if not check_if_shield():
							if not check_if_bow():
								if not check_if_arrow():
									label.text = str(item.name)
									label.visible = true
	if chest == true:
		equip.disabled = true
		equip.visible = false
		unequip.disabled = true
		unequip.visible = false
		discard.disabled = true
		discard.visible = false
		drop.visible = false
		drop.disabled = true
		size = $VBoxContainer.size

func check_if_helmet():
	if item.type == "helmet" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "helmet" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_chest():
	if item.type == "chest" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "chest" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_gloves():
	if item.type == "gloves" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "gloves" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_legs():
	if item.type == "legs" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "legs" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_weapon():
	if item.type == "weapon" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "weapon" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_shield():
	if item.type == "shield" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "shield" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func check_if_bow():
	if item.type == "bow" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "bow" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true
func check_if_arrow():
	if item.type == "arrow" and player and inventory and not inventory_slot.is_equipment_slot:
		equip.disabled = false
		equip.visible = true
		return true
	elif item.type == "arrow" and player and inventory and inventory_slot.is_equipment_slot:
		unequip.disabled = false
		unequip.visible = true
		return true

func try_equip_helmet():
	if item.type == "helmet":
		if equipment.slots[0].item != null:
			player.collect(equipment.slots[0].item)
		equipment.slots[0].item = item
		equipment.slots[0].amount = 1
		return true

func try_equip_chest():
	if item.type == "chest":
		if equipment.slots[1].item != null:
			player.collect(equipment.slots[1].item)
		equipment.slots[1].item = item
		equipment.slots[1].amount = 1
		return true

func try_equip_gloves():
	if item.type == "gloves":
		if equipment.slots[2].item != null:
			player.collect(equipment.slots[2].item)
		equipment.slots[2].item = item
		equipment.slots[2].amount = 1
		return true

func try_equip_legs():
	if item.type == "legs":
		if equipment.slots[3].item != null:
			player.collect(equipment.slots[3].item)
		equipment.slots[3].item = item
		equipment.slots[3].amount = 1
		return true

func try_equip_weapon():
	if item.type == "weapon":
		if equipment.slots[4].item != null:
			player.collect(equipment.slots[4].item)
		if player.SWORD != null:
			player.SWORD.queue_free()
			player.swordswingable = false
			player.swordout = false
		equipment.slots[4].item = item
		equipment.slots[4].amount = 1
		return true

func try_equip_shield():
	if item.type == "shield":
		if equipment.slots[5].item != null:
			player.collect(equipment.slots[5].item)
		if player.SHIELD != null:
			player.SHIELD.queue_free()
			player.shieldblocking = false
		equipment.slots[5].item = item
		equipment.slots[5].amount = 1
		return true

func try_equip_bow():
	if item.type == "bow":
		if equipment.slots[6].item != null:
			player.collect(equipment.slots[6].item)
		if player.BOW != null:
			player.BOW.queue_free()
		equipment.slots[6].item = item
		equipment.slots[6].amount = 1
		return true

func try_equip_arrow():
	if item.type == "arrow":
		if equipment.slots[7].item != null:
			for i in equipment.slots[7].amount:
				player.collect(equipment.slots[7].item)
		equipment.slots[7].item = item
		equipment.slots[7].amount = inventory_slot.slot_keep.amount
		return true

func try_unequip_helmet():
	if item.type == "helmet":
		player.collect(equipment.slots[0].item)
		equipment.slots[0].item = null
		equipment.slots[0].amount = 0
		return true

func try_unequip_chest():
	if item.type == "chest":
		player.collect(equipment.slots[1].item)
		equipment.slots[1].item = null
		equipment.slots[1].amount = 0
		return true

func try_unequip_gloves():
	if item.type == "gloves":
		player.collect(equipment.slots[2].item)
		equipment.slots[2].item = null
		equipment.slots[2].amount = 0
		return true

func try_unequip_legs():
	if item.type == "legs":
		player.collect(equipment.slots[3].item)
		equipment.slots[3].item = null
		equipment.slots[3].amount = 0
		return true

func try_unequip_weapon():
	if item.type == "weapon":
		player.collect(equipment.slots[4].item)
		if player.SWORD != null:
			player.SWORD.queue_free()
			player.swordswingable = false
			player.swordout = false
		equipment.slots[4].item = null
		equipment.slots[4].amount = 0
		return true

func try_unequip_shield():
	if item.type == "shield":
		player.collect(equipment.slots[5].item)
		if player.SHIELD != null:
			player.SHIELD.queue_free()
			player.shieldblocking = false
		equipment.slots[5].item = null
		equipment.slots[5].amount = 0
		return true

func try_unequip_bow():
	if item.type == "bow":
		player.collect(equipment.slots[6].item)
		if player.BOW != null:
			player.BOW.queue_free()
		equipment.slots[6].item = null
		equipment.slots[6].amount = 0
		return true

func try_unequip_arrow():
	if item.type == "arrow":
		for i in equipment.slots[7].amount:
			player.collect(equipment.slots[7].item)
		equipment.slots[7].item = null
		equipment.slots[7].amount = 0
		return true

func clear_all():
	var hud_elements = []
	for i in get_children():
		if i.is_in_group("Control"):
			hud_elements.append(i)
	for i in hud_elements:
		if i == Button:
			i.disabled = true
		i.visible = false

func _on_use_pressed() -> void:
	inventory.close()
	player.use_item(item.name)
	inventory_slot.slot_keep.amount -= 1
	if inventory_slot.slot_keep.amount == 0:
		inventory_slot.slot_keep.item = null
	queue_free()


func _on_equip_pressed() -> void:
	if not try_equip_helmet():
		if not try_equip_chest():
			if not try_equip_gloves():
				if not try_equip_legs():
					if not try_equip_weapon():
						if not try_equip_shield():
							try_equip_bow()
	if try_equip_arrow():
		inventory_slot.slot_keep.amount -= inventory_slot.slot_keep.amount
		inventory_slot.slot_keep.item = null
	else:
		inventory_slot.slot_keep.amount -= 1
		if inventory_slot.slot_keep.amount == 0:
			inventory_slot.slot_keep.item = null
	player.update_status()
	inventory.update_slots()
	inventory.play_equip_sound()
	queue_free()


func _on_unequip_pressed() -> void:
	if not try_unequip_helmet():
		if not try_unequip_chest():
			if not try_unequip_gloves():
				if not try_unequip_legs():
					if not try_unequip_weapon():
						if not try_unequip_shield():
							if not try_unequip_bow():
								try_unequip_arrow()
	player.update_status()
	inventory.update_slots()
	inventory.play_unequip_sound()
	queue_free()


func _on_inspect_pressed() -> void:
	var inspect = load(inspect_menu_path)
	inspect = inspect.instantiate()
	inspect.item = item
	inventory.add_child(inspect)
	inspect.position.x = (DisplayServer.screen_get_size()[0] / 4) - 100
	inspect.position.y = (DisplayServer.screen_get_size()[1] / 4) - 100
	inventory.inspect_windows.append(inspect)
	queue_free()


func _on_discard_pressed() -> void:
	player.inventory.slots[item_run].item = null
	player.inventory.slots[item_run].amount = 0
	inventory.update_slots()
	queue_free()


func _on_drop_pressed() -> void:
	var item_drop = load("res://Scenes/Items/item_pickup.tscn")
	item_drop = item_drop.instantiate()
	item_drop.global_position = player.global_position
	item_drop.item_id = load(item.resource_path)
	var item_visual = load(item_drop.item_id.mesh)
	item_visual = item_visual.instantiate()
	item_drop.add_child(item_visual)
	item_drop.item_visual = item_visual
	player.inventory.slots[item_run].amount -= 1
	if player.inventory.slots[item_run].amount == 0: player.inventory.slots[item_run].item = null
	inventory.update_slots()
	inventory.play_drop_sound()
	get_tree().get_root().get_child(1).add_child(item_drop)
	queue_free()

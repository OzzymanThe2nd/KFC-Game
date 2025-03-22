extends Node
var level
var loading_image
@export var strength = 1
@export var healthmax = 25
@export var healthcurrent = 25
@export var protslash = 0
@export var protcrush = 0
@export var protstab = 0
@export var equiped = []
@export var swingspeed = 1
var loading_image_path = preload("res://Scenes/Menus/save_loading.tscn")
var swapping_item = null
var display_damage = 0
var keepplayer
var store_inven
var store_equip 
var warp_to 
var warpspots_unlocked = [true,true,false,false,false,false,false,false]

func update_stats(player, helmet, chest, gloves, legs, weapon, shield, bow):
	keepplayer = player
	var updated_protslash = 0
	var updated_protcrush = 0
	var updated_protstab = 0
	var item_damage = 0
	if helmet:
		if helmet.name == "debug helmet":
			updated_protslash += 3
			updated_protcrush += 3
			updated_protstab += 3
		
	if chest:
		if chest.name == "debug chest":
			updated_protslash += 3
			updated_protcrush += 3
			updated_protstab += 3
		
	if gloves:
		if gloves.name == "debug gloves":
			updated_protslash += 3
			updated_protcrush += 3
			updated_protstab += 3
		
	if legs:
		if legs.name == "debug legs":
			updated_protslash += 3
			updated_protcrush += 3
			updated_protstab += 3
	if weapon:
		if weapon.name == "debug sword":
			player.loadSWORD = preload("res://Scenes/Items/sword.tscn")
			item_damage = 4
	else: player.loadSWORD = null
	if shield:
		if shield.name == "debug shield":
			player.loadSHIELD = preload("res://Scenes/Items/shield.tscn")
	else: player.loadSHIELD = null
	if bow:
		if bow.name == "debug bow":
			player.loadBOW = preload("res://Scenes/Items/bow.tscn")
	else: player.loadBOW = null
	protslash = updated_protslash
	protcrush = updated_protcrush
	protstab = updated_protstab
	display_damage = roundi(item_damage + (strength / 2))

func save():
	var save_dictionary = {
		"filename" : "Playerstatus",
		"healthcurrent" : healthcurrent,
		"healthmax" : healthmax,
		"strength" : strength,
		"warpspots_unlocked" : warpspots_unlocked
		}
	return save_dictionary

func level_change(level, warp_position : Vector3):
	var load_level = level
	warp_to = warp_position
	store_equip = keepplayer.equipment
	store_inven = keepplayer.inventory
	loading_image_appear()
	await get_tree().process_frame
	ResourceLoader.load_threaded_request(load_level)
	while ResourceLoader.load_threaded_get_status(load_level) != 3:
		pass
	if ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(load_level))
		loading_image_clear()

func save_all(player):
	var current_inven = player.inventory
	var current_equiped = player.equipment
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	save_nodes.append_array(get_tree().get_nodes_in_group("Level"))
	var self_save_data = save()
	var self_json_string = JSON.stringify(self_save_data)
	save_file.store_line(self_json_string)
	if ResourceSaver.save(current_inven,"res://Scripts/Inventory/player_inven.tres") != OK:
		print("le fu")
	if ResourceSaver.save(current_equiped,"res://Scripts/Inventory/player_equipped.tres") != OK:
		print("le fuck...")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func loading_image_appear():
	loading_image = loading_image_path.instantiate()
	get_tree().get_root().add_child(loading_image)

func load_game():
	loading_image_appear()
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var level_node = get_tree().get_nodes_in_group("Level")
	for i in level_node:
		i.queue_free()
	while save_file.get_position() < save_file.get_length():
		var level_json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var level_json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var level_parse_result = level_json.parse(level_json_string)
		if not level_parse_result == OK:
			print("JSON Parse Error: ", level_json.get_error_message(), " in ", level_json_string, " at line ", level_json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = level_json.data
		if not node_data.keys().has("level"):
			continue
		else:
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
			level = new_object
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "pos_z":
					continue
				new_object.set(i, node_data[i])
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var delete_nodes = get_tree().get_nodes_in_group("Reset_On_Load")
	for i in delete_nodes:
		i.queue_free()
	for i in save_nodes:
		i.queue_free()
	for i in 5: await get_tree().process_frame
	save_file.seek(0)
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	#var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		if node_data["filename"] == "Playerstatus":
			healthcurrent = node_data["healthcurrent"]
			healthmax = node_data["healthmax"]
			strength = node_data["strength"]
		elif not node_data.keys().has("level"):
			var new_object = load(node_data["filename"]).instantiate()
			if node_data["parent"] == "level":
				level.add_child(new_object)
			else:
				get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])

			# Now we set the remaining variables.
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "pos_z":
					continue
				new_object.set(i, node_data[i])
	loading_image_clear()

func loading_image_clear():
	if loading_image != null:
		loading_image.queue_free()

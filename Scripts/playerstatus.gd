extends Node
var level
var viewer
var load_queued = false
var player_level : int = 1
var player_experience : int = 0
var maxlevel : bool = false
var loading_new_game : bool = false
var loading_images = []
var strength : int = 1
var strength_exp : int = 0
var archery : int = 1
var archery_exp : int = 0
var magic : int = 1
var magic_exp : int = 0
var arrow_damage : int
var bow_damage : int
var chest_inven = load("res://Scripts/Inventory/chest_inventory.tres")
var temp_inven 
var temp_equip
var spellcasting_unlocked : bool = true
@export var healthmax : int = 40
@export var healthcurrent : int = 40
@export var protslash : int = 0
@export var protcrush : int = 0
@export var protstab : int = 0
@export var equiped = []
@export var swingspeed = 1
@export var base_magic_points : int = 100
@export var magic_points : int = 100
var loading_image_path = preload("res://Scenes/Menus/save_loading.tscn")
var swapping_item = null
var display_damage = 0
var keepplayer
var store_inven
var store_equip 
var warp_to 
var warpspots_unlocked = [true,true,false,false,false,false,false,false]
var unlocked_spells = ["fireball","heal"]
var equipped_spells = ["fireball","heal"]
#Formatting: Slash protection, crush protection, stab protection
var armorstats_dict = {
	"rusted helmet": [3,3,3],
	"rusted chest": [3,3,3],
	"rusted gloves": [3,3,3],
	"rusted platelegs": [3,3,3],
}

var swords_dict = {
	"shoddy dagger": ["res://Scenes/Items/sword.tscn", 3]
}

var shield_dict = {
	"standard shield": "res://Scenes/Items/shield.tscn"
}

var bow_dict = {
	"shortbow": ["res://Scenes/Items/bow.tscn", 2]
}
func reset_to_default():
	bow_damage = 0
	arrow_damage = 0
	level = null
	player_level = 1
	player_experience = 0
	maxlevel = false
	loading_new_game = false
	loading_images = []
	strength = 1
	strength_exp = 0
	archery = 1
	archery_exp = 0
	magic = 1
	magic_exp = 0
	chest_inven = load("res://Scripts/Inventory/chest_inventory.tres")
	temp_inven = null
	temp_equip = null
	healthmax = 40
	healthcurrent = 40
	protslash = 0
	protcrush = 0
	protstab = 0
	equiped = []
	swingspeed = 1
	loading_image_path = preload("res://Scenes/Menus/save_loading.tscn")
	swapping_item = null
	display_damage = 0
	keepplayer = null
	store_inven = null
	store_equip = null
	warp_to = null
	warpspots_unlocked = [true,true,false,false,false,false,false,false]
	unlocked_spells = ["fireball", "heal"]
	magic_points = 100
	equipped_spells = ["fireball","heal"]
	base_magic_points = 100

func update_stats(player, helmet, chest, gloves, legs, weapon, shield, bow, arrow):
	keepplayer = player
	var updated_protslash = 0
	var updated_protcrush = 0
	var updated_protstab = 0
	var item_damage = 0
	if helmet:
		updated_protslash += (armorstats_dict[helmet.name])[0]
		updated_protcrush += (armorstats_dict[helmet.name])[1]
		updated_protstab += (armorstats_dict[helmet.name])[2]
		
	if chest:
		updated_protslash += (armorstats_dict[chest.name])[0]
		updated_protcrush += (armorstats_dict[chest.name])[1]
		updated_protstab += (armorstats_dict[chest.name])[2]
		
	if gloves:
		updated_protslash += (armorstats_dict[gloves.name])[0]
		updated_protcrush += (armorstats_dict[gloves.name])[1]
		updated_protstab += (armorstats_dict[gloves.name])[2]
		
	if legs:
		updated_protslash += (armorstats_dict[legs.name])[0]
		updated_protcrush += (armorstats_dict[legs.name])[1]
		updated_protstab += (armorstats_dict[legs.name])[2]
		
	if weapon:
		player.loadSWORD = load((swords_dict[weapon.name])[0])
		item_damage = (swords_dict[weapon.name])[1]
	else: player.loadSWORD = null
	
	if shield:
		player.loadSHIELD = load(shield_dict[shield.name])
	else: player.loadSHIELD = null
	
	if bow:
		player.loadBOW = load(bow_dict[bow.name][0])
		bow_damage = bow_dict[bow.name][1]
	else: player.loadBOW = null
	
	if arrow:
		if arrow.name == "basic arrow":
			arrow_damage = 1
			
	protslash = updated_protslash
	protcrush = updated_protcrush
	protstab = updated_protstab
	var strengthmod = 1 + (strength / 18)
	display_damage = item_damage * strengthmod

func save():
	var save_dictionary = {
		"filename" : "Playerstatus",
		"player_level" : int(player_level),
		"player_experience" : int(player_experience),
		"maxlevel" : bool(maxlevel),
		"healthcurrent" : int(healthcurrent),
		"healthmax" : int(healthmax),
		"strength" : int(strength),
		"strength_exp" : int(strength_exp),
		"archery" : int(archery),
		"archery_exp" : int(archery_exp),
		"magic" : int(magic),
		"magic_exp" : int(magic_exp),
		"warpspots_unlocked" : warpspots_unlocked,
		"base_magic_points" : int(base_magic_points),
		"unlocked_spells" : unlocked_spells,
		"equipped_spells" : equipped_spells,
		"magic_points" : magic_points,
		"spellcasting_unlocked" : spellcasting_unlocked
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
	if keepplayer != null: keepplayer.get_parent().queue_free()
	for i in AreaData.free_on_load:
		AreaData.free_on_load.erase(i)
		if is_instance_valid(i): i.queue_free()
	while ResourceLoader.load_threaded_get_status(load_level) != 3:
		pass
	if ResourceLoader.THREAD_LOAD_LOADED:
		#print(viewer.get_node("Game").get_children())
		#viewer.get_node("Game").get_children()[0].queue_free()
		viewer.get_node("Game").add_child((ResourceLoader.load_threaded_get(load_level)).instantiate())
		loading_image_clear()

func save_all(player):
	var current_inven = player.inventory
	var current_equiped = player.equipment
	var current_chest = chest_inven
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	save_nodes.append_array(get_tree().get_nodes_in_group("Level"))
	var self_save_data = save()
	var self_json_string = JSON.stringify(self_save_data)
	save_file.store_line(self_json_string)
	var area_save_data = AreaData.save()
	var area_json_string = JSON.stringify(area_save_data)
	save_file.store_line(area_json_string)
	if ResourceSaver.save(current_inven,"res://Scripts/Inventory/player_inven.tres") != OK:
		print("le fu")
	if ResourceSaver.save(current_equiped,"res://Scripts/Inventory/player_equipped.tres") != OK:
		print("le fuck...")
	if ResourceSaver.save(current_chest,"res://Scripts/Inventory/chest_inventory.tres") != OK:
		print("le shite")
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
	var loading_image = loading_image_path.instantiate()
	loading_images.append(loading_image)
	get_tree().get_root().add_child(loading_image)

func exp_gain(x):
	var level_up_threshold = int(100 * (1.25 ** player_level))
	player_experience += x
	if player_experience >= level_up_threshold:
		player_level_up(player_experience - level_up_threshold)

func skill_exp_gain(skill : String, value : int):
	var level_up_threshold
	if skill == "strength":
		level_up_threshold = int(100 * (1.25 ** strength))
		strength_exp += value
		if strength_exp >= level_up_threshold:
			skill_level_up("strength", strength_exp - level_up_threshold)
	elif skill == "archery":
		level_up_threshold = int(100 * (1.25 ** archery))
		archery_exp += value
		if archery_exp >= level_up_threshold:
			skill_level_up("archery", archery_exp - level_up_threshold)
	elif skill == "magic":
		level_up_threshold = int(100 * (1.25 ** magic))
		magic_exp += value
		if magic_exp >= level_up_threshold:
			skill_level_up("magic", magic_exp - level_up_threshold)

func player_level_up(x):
	keepplayer.show_text("Level Up", 4.5)
	player_experience = x
	player_level += 1
	healthmax = int(healthmax * 1.1)
	if player_level >= 25:
		maxlevel = true
	keepplayer.update_status()

func skill_level_up(skill : String, value : int):
	if skill == "strength":
		strength += 1
		strength_exp = value
		keepplayer.show_text("Strength Level Up", 4.5)
	if skill == "archery":
		archery += 1
		archery_exp = value
		keepplayer.show_text("Archery Level Up", 4.5)
	if skill == "magic":
		magic += 1
		magic_exp = value
		keepplayer.show_text("Magic Level Up", 4.5)
	keepplayer.update_status()

func load_game():
	loading_new_game = false
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	for i in AreaData.free_on_load:
		AreaData.free_on_load.erase(i)
		if is_instance_valid(i): i.queue_free()
	loading_image_appear()
	while save_file.get_position() < save_file.get_length():
		var area_json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var area_json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var area_parse_result = area_json.parse(area_json_string)
		if not area_parse_result == OK:
			print("JSON Parse Error: ", area_json.get_error_message(), " in ", area_json_string, " at line ", area_json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = area_json.data
		if not node_data["filename"] == "AreaData":
			continue
		else:
			for i in node_data.keys():
				AreaData.set(i, node_data[i])
	var level_node = get_tree().get_nodes_in_group("Level")
	for i in level_node:
		i.queue_free()
	for i in 5: await get_tree().process_frame
	save_file.seek(0)
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
			player_level = int(node_data["player_level"])
			player_experience = int(node_data["player_experience"])
			maxlevel = bool(node_data["maxlevel"])
			healthcurrent = int(node_data["healthcurrent"])
			healthmax = int(node_data["healthmax"])
			strength = int(node_data["strength"])
			strength_exp = int(node_data["strength_exp"])
			archery_exp = int(node_data["archery_exp"])
			magic_exp = int(node_data["magic_exp"])
			unlocked_spells = node_data["unlocked_spells"]
			equipped_spells = node_data["equipped_spells"]
			base_magic_points = node_data["base_magic_points"]
			magic_points = node_data["magic_points"]
			warpspots_unlocked = node_data["warpspots_unlocked"]
			spellcasting_unlocked = node_data["spellcasting_unlocked"]
		elif not node_data.keys().has("level") and not node_data["filename"] == "AreaData":
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
	for i in loading_images:
		loading_images.erase(i)
		if is_instance_valid(i): i.queue_free()

func clear_nodes():
	if keepplayer != null:
		keepplayer.queue_free()
	if level != null:
		level.queue_free()

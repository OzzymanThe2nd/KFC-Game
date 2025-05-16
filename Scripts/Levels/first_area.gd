extends Node3D
var paused_by_pause_menu : bool = false
var item_pickup = preload("res://Scenes/Items/item_pickup.tscn")
@onready var player = $Player

func save():
	var save_dictionary = {
		"level" : "test",
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, 
		"pos_y" : position.y,
		"pos_z" : position.z,
		"process_mode" : process_mode
	}
	return save_dictionary

func _ready() -> void:
	if AreaData.first_area_sword_grabbed == false:
		var startsword = item_pickup.instantiate()
		startsword.despawn_timer = false
		$StartSword.add_child(startsword)
		startsword.global_position = $StartSword.global_position
		startsword.grabbed.connect(_on_startsword_grabbed)
		startsword.set_id("res://Scripts/Inventory/debug sword.tres")
		startsword.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_startsword_grabbed():
	AreaData.first_area_sword_grabbed = true
	var button = str(InputMap.action_get_events("inventory")[0].as_text()).split(" ")[0]
	Playerstatus.keepplayer.show_text("Press %s to open the inventory" %[str(button)], 5)

func _on_player_dead() -> void:
	$Player/CamNode3D/CanvasLayer/Deathscreen.visible = true
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"):
			if paused_by_pause_menu == false and get_tree().paused == false:
				if (player.get_node("CamNode3D/CamSmooth/PCamera/Interact")).is_colliding():
					print("working")
					(player.get_node("%InteractPrompt")).visible = false
				get_tree().paused = true
				$"Pause Menu".visible = true
				paused_by_pause_menu = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			elif paused_by_pause_menu == true and get_tree().paused == true:
				if (player.get_node("CamNode3D/CamSmooth/PCamera/Interact")).is_colliding():
					(player.get_node("%InteractPrompt")).visible = true
				get_tree().paused = false
				$"Pause Menu".visible = false
				paused_by_pause_menu = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if Input.is_action_just_pressed("0"):
			print(get_children())

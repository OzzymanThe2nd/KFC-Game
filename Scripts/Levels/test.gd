extends Node3D
var paused_by_pause_menu : bool = false

#func _ready() -> void:
	#Playerstatus.load_game()

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

func _on_player_dead() -> void:
	$Player/CamNode3D/CanvasLayer/Deathscreen.visible = true
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"):
			if paused_by_pause_menu == false and get_tree().paused == false:
				get_tree().paused = true
				$"Pause Menu".visible = true
				paused_by_pause_menu = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			elif paused_by_pause_menu == true and get_tree().paused == true:
				get_tree().paused = false
				$"Pause Menu".visible = false
				paused_by_pause_menu = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if Input.is_action_just_pressed("0"):
			print(get_children())


func _on_dogshit_entrance_body_entered(body: Node3D) -> void:
	Playerstatus.keepplayer.travel_with_fade("res://Scenes/Levels/dogshit.tscn", Vector3(0,0,0))

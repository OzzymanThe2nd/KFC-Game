extends Control
var level = load("res://Scenes/Levels/test.tscn")
var settings = load("res://Scenes/Menus/settings.tscn")
var loading_path = "res://Scenes/Menus/loading.tscn"

func _ready() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		$Button3.disabled = true
	else:
		$Button3.disabled = false

func _on_button_pressed() -> void:
	var children_nodes = get_tree().root.get_children()
	for i in children_nodes:
		if i is Node3D:
			i.queue_free()
	Playerstatus.reset_to_default()
	AreaData.reset_to_default()
	Playerstatus.loading_new_game = true
	Playerstatus.loading_image_appear()
	get_tree().change_scene_to_file(loading_path)

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(settings)


func _on_button_3_pressed() -> void:
	Playerstatus.loading_image_appear()
	get_tree().change_scene_to_file(loading_path)
	Playerstatus.load_queued = true


func _on_button_4_pressed() -> void:
	get_tree().quit()

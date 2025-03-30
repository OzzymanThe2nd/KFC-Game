extends Control

func _on_quit_pressed() -> void:
	get_tree().paused = false
	if Playerstatus.keepplayer != null:
		Playerstatus.keepplayer.queue_free()
	get_tree().change_scene_to_packed(load("res://Scenes/Menus/title.tscn"))

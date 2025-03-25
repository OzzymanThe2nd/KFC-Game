extends Control
var level = load("res://Scenes/Levels/test.tscn")
var settings = load("res://Scenes/Menus/settings.tscn")
var loading_path = "res://Scenes/Menus/loading.tscn"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(loading_path)

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(settings)


func _on_button_3_pressed() -> void:
	Playerstatus.load_game()
	queue_free()


func _on_button_4_pressed() -> void:
	get_tree().quit()

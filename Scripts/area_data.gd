extends Node
var first_area_sword_grabbed : bool = false

# Called when the node enters the scene tree for the first time.
func reset_to_default():
	first_area_sword_grabbed = false

func save():
	var save_dictionary = {
		"filename" : get_scene_file_path(),
		"first_area_sword_grabbed" : false
	}
	return save_dictionary

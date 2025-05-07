extends Node
var first_area_sword_grabbed : bool = false

# Called when the node enters the scene tree for the first time.
func reset_to_default():
	first_area_sword_grabbed = false

func save():
	var save_dictionary = {
		"filename" : "AreaData",
		"first_area_sword_grabbed" : first_area_sword_grabbed
	}
	return save_dictionary

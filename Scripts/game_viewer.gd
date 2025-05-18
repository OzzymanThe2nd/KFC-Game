extends SubViewportContainer
var first_level = "res://Scenes/Levels/test.tscn"
var loading : bool = true
var loading_destination 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Playerstatus.viewer = self
	if Playerstatus.load_queued: loading_from_save()
	elif Playerstatus.loading_new_game: 
		ResourceLoader.load_threaded_request(first_level)
		loading_destination = first_level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loading:
		if ResourceLoader.THREAD_LOAD_LOADED:
			$Game.add_child((ResourceLoader.load_threaded_get(loading_destination)).instantiate())
			loading = false

func loading_from_save():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
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
		if not node_data.keys().has("level"):
			continue
		else:
			var new_object = load(node_data["filename"]).instantiate()
			$Game.add_child(new_object)
			loading = false

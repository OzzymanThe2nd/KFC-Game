extends Node3D
var player
var active : bool = false

# Called when the node enters the scene tree for the first time.
func interact_with_player(player_grab):
	player = player_grab
	player.pixelate_off()
	if Playerstatus.healthcurrent < Playerstatus.healthmax:
		player.heal(INF)
	player.gain_magic_points(INF)
	Playerstatus.save_all(player)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	active = true
	$Menu.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and get_tree().paused == true and active == true:
			await get_tree().process_frame
			close()

func close():
	active = false
	$Menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_save_button_pressed() -> void:
	if active == true:
		Playerstatus.save_all(player)

func _on_load_button_pressed() -> void:
	if active == true:
		Playerstatus.load_game()

func _on_close_button_pressed() -> void:
	if active == true:
		close()


func _on_spell_button_pressed() -> void:
	pass # Replace with function body.

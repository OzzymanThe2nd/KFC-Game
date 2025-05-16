extends Node3D
var player
var active : bool = false
var warpspots = []
var selected_warpspot
var warplevel1 = "res://Scenes/Levels/test.tscn"
var warplevel2 = "res://Scenes/Levels/dogshit.tscn"
@onready var locked_rects = [%ColorRect1, %ColorRect2, %ColorRect3, %ColorRect4, %ColorRect5, %ColorRect6, %ColorRect7, %ColorRect8]
@onready var icons = [%TextureRect1, %TextureRect2, %TextureRect3, %TextureRect4, %TextureRect5, %TextureRect6, %TextureRect7, %TextureRect8]
var unlocked_icons = ["res://textures/bricks256.png","res://textures/concrete256_3.png","res://textures/darkgrass.png","res://textures/dirt32.png","res://textures/bricks256.png","res://textures/concrete256_3.png","res://textures/darkgrass.png","res://textures/dirt32.png"]

func interact_with_player(player_grab):
	player = player_grab
	player.hud_pixelate(false)
	player.show_hud(false)
	player.show_interact_prompt(false)
	update_visuals()
	$Menu.visible = true
	active = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and get_tree().paused == true and active == true:
			await get_tree().process_frame
			close()

func close():
	active = false
	player.show_hud(true)
	player.hud_pixelate(true)
	player.show_interact_prompt(true)
	$Menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func update_visuals():
	var run = 0
	for i in Playerstatus.warpspots_unlocked:
		if i == true:
			locked_rects[run].visible = false
			icons[run].visible = true
			icons[run].texture = load(unlocked_icons[run])
		else:
			icons[run].visible = false
			locked_rects[run].visible = true
		run += 1

func _on_button_1_pressed() -> void:
	if Playerstatus.warpspots_unlocked[0] == true:
		Playerstatus.level_change(warplevel1, Vector3(0,0,0))
	#if Playerstatus.warpspots_unlocked[0] == true:
		#selected_warpspot = warpspots[0]


func _on_button_2_pressed() -> void:
	if Playerstatus.warpspots_unlocked[1] == true:
		Playerstatus.level_change(warplevel2, Vector3(0,0,0))
	#if Playerstatus.warpspots_unlocked[1] == true:
		#selected_warpspot = warpspots[1]


func _on_button_3_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[2] == true:
		#selected_warpspot = warpspots[2]


func _on_button_4_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[3] == true:
		#selected_warpspot = warpspots[3]


func _on_button_5_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[4] == true:
		#selected_warpspot = warpspots[4]


func _on_button_6_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[5] == true:
		#selected_warpspot = warpspots[5]


func _on_button_7_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[6] == true:
		#selected_warpspot = warpspots[6]


func _on_button_8_pressed() -> void:
	pass
	#if Playerstatus.warpspots_unlocked[7] == true:
		#selected_warpspot = warpspots[7]

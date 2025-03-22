extends Node3D
@onready var world = $WorldEnvironment.environment
var current_colour = "red"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn_red():
	world.background_color = "9b0000"
	world.ambient_light_color = "ff0000"
	world.fog_light_color = "ff0000"

func turn_green():
	world.background_color = "009b00"
	world.ambient_light_color = "00ff00"
	world.fog_light_color = "00ff00"

func turn_blue():
	world.background_color = "00009b"
	world.ambient_light_color = "0000ff"
	world.fog_light_color = "0000ff"


func _on_audio_stream_player_3d_finished() -> void:
	$AudioStreamPlayer3D.play()
	if current_colour == "red":
		turn_green()
		current_colour = "green"
	elif current_colour == "green":
		turn_blue()
		current_colour = "blue"
	elif current_colour == "blue":
		turn_red()
		current_colour = "red"

#GAAAAAAAAAAAAAH I HATE GIT

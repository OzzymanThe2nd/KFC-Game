extends Node3D
@export var open : bool = false

func _ready() -> void:
	if open == true:
		opening(false)

func interact():
	if open == false and not $AnimationPlayer.is_playing(): opening()
	elif open == true and not $AnimationPlayer.is_playing(): closing()

func opening(autoshut : bool = true):
	open = true
	$AnimationPlayer.play("open")
	if autoshut:
		$SelfShut.start()

func closing():
	open = false
	$AnimationPlayer.play("close")
	$SelfShut.stop()

func _on_self_shut_timeout() -> void:
	if open and not $AnimationPlayer.is_playing(): closing()

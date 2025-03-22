extends Node3D
class_name bow_base
@export var dmg : int
var busy = true
@onready var loadARROW = preload("res://Scenes/Items/arrow.tscn")
signal bow_unequipped

func _ready() -> void:
	busy = true
	$AnimationPlayer.play("equip")



func shoot():
	if busy != true:
		busy = true
		$AnimationPlayer.play("shoot")

func shoot2():
	$AnimationPlayer.play("shoot2")
	var ARROW = loadARROW.instantiate()
	%ArrowSpawn.add_child(ARROW)
	ARROW.dmg = dmg

func putaway():
	busy = true
	$AnimationPlayer.play("unequip")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "equip" or "shoot2":
		busy = false
	if anim_name == "shoot":
		busy = true
		shoot2()
	if anim_name == "unequip":
		bow_unequipped.emit()
		queue_free()

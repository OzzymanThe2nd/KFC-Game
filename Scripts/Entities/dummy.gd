extends CharacterBody3D
@export var health = INF
var dmg_num = preload("res://Scenes/Entities/dmg_num.tscn")
var player = null

func damage(x):
	health -= x
	var dmg_num_active = dmg_num.instantiate()
	add_sibling(dmg_num_active)
	dmg_num_active.global_position = global_position
	dmg_num_active.global_position.y += 1.5
	dmg_num_active.show_text(x)
	$AnimationPlayer.play("damage")

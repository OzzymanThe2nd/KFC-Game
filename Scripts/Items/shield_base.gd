extends Node

class_name shield_base
var busy = true
var stopblocking = false
var player = null
var shield_damaged = false
@export var healthmax : int 
@export var health : int 
@export var blocking = false
signal shield_unequipped

func _ready() -> void:
	$AnimationPlayer.play("equip")
	player = Playerstatus.keepplayer

func shield_damage(x):
	health -= x
	(player.get_node("PlayerAnim")).play("shield_recoil")
	if health <= 0:
		busy = true
		shield_damaged = true
		stopblocking = false
		blocking = false
		$AnimationPlayer.play("return_block")

func block():
	$AnimationPlayer.play("block")
	health = healthmax

func putaway():
	busy = true
	$AnimationPlayer.play("unequip")

func _physics_process(delta: float) -> void:
	if $AnimationPlayer.current_animation == "wobble_while_blocked" and stopblocking == true:
		stopblocking = false
		blocking = false
		$AnimationPlayer.play("return_block")
	if $AnimationPlayer.is_playing() == false and blocking == false:
		$AnimationPlayer.play("idle_bounce")
	if blocking != true:
		%CollisionShape3D.disabled = true
	else: %CollisionShape3D.disabled = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unequip":
		shield_unequipped.emit()
		queue_free()
	if anim_name == "return_block":
		player.shieldblocking = false
		health = healthmax
		if shield_damaged == true:
			shield_damaged = false
			busy = false
	if anim_name == "equip": busy = false
	if anim_name == "block":
		busy = false
		$AnimationPlayer.play("wobble_while_blocked")

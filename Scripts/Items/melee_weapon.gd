extends Node
class_name melee_weapon
var hitmarker = preload("res://Scenes/Entities/sword_hitmarker.tscn")
@export var second_swing_possible : bool = false
var alreadyhit = []
var bouncing = false
@export var basedmg : int
var swinging=false
var player = null
var unsheathing = true
var busy = true
var temppos = Vector3(0,0,0)
var playerstrength = Playerstatus.strength
var dmg = basedmg + (playerstrength / 2)
var swingspeed = Playerstatus.swingspeed 
var swingspeed_slow = swingspeed * 0.08
var hit_recovery : bool = false
signal sword_unequipped
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("unsheath")
	player = get_parent()
	for i in range(0, 5):
		player = player.get_parent()

func second_swing():
	alreadyhit.clear()
	dmg = basedmg + (playerstrength / 2)
	second_swing_possible = false
	%WallDet2.enabled = false
	%EnemyDet.enabled = false
	$AnimationPlayer.play("second_swing")
	$AnimationPlayer.speed_scale=swingspeed
	swinging = true
	busy = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if swinging == true:
		if %EnemyDet.is_colliding():
			var body = %EnemyDet.get_collider()
			if body.has_method("damage"):
				if not alreadyhit.has(body):
					var marker = hitmarker.instantiate()
					add_child(marker)
					if $AnimationPlayer.current_animation == "second_swing": marker.process_material = load("res://Resources/sword_hitmarker_second_hit.tres")
					marker.global_position = %EnemyDet.get_collision_point()
					body.damage(dmg)
					Playerstatus.skill_exp_gain("strength", dmg)
					dmg /= 2
					alreadyhit.append(body)
					$HitTimer.start()
					$AnimationPlayer.speed_scale = swingspeed_slow
		if %WallDet2.is_colliding() and bouncing == false:
			bouncing = true
			temppos = self.position
			self.global_position = %WallDet2.get_collision_point()
			$AnimationPlayer.speed_scale = swingspeed
			$AnimationPlayer.play("bounce")
	if hit_recovery:
		if not $AnimationPlayer.speed_scale >= swingspeed:
			$AnimationPlayer.speed_scale += 0.01
		else:
			hit_recovery = false
			$AnimationPlayer.speed_scale = swingspeed
	if $AnimationPlayer.current_animation == "RESET" and player.velocity.x == 0 and player.velocity.z == 0 or $AnimationPlayer.is_playing() == false and player.velocity.x == 0 and player.velocity.z == 0:
		$AnimationPlayer.play("idle_bounce")


func swing():
	if unsheathing == false:
		second_swing_possible = false
		%WallDet2.enabled = true
		%EnemyDet.enabled = true
		$AnimationPlayer.play("swing")
		$AnimationPlayer.speed_scale = swingspeed
		swinging = true
		busy = true

func putaway():
	second_swing_possible = false
	busy = true
	$AnimationPlayer.play("sheath")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "swing" or anim_name == "bounce" or "second_swing":
		if bouncing == true:
			$sword.visible=false
			self.position = temppos
			bouncing = false
		second_swing_possible = false
		swinging = false
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.speed_scale = 1
		busy = false
		player.swordout = false
		$sword.visible = true
		alreadyhit.clear()
		dmg = roundi(basedmg+(playerstrength / 2))
	if anim_name == "unsheath":
		unsheathing = false
		busy = false
		second_swing_possible = false
	if anim_name == "sheath":
		sword_unequipped.emit()


func _on_hit_timer_timeout() -> void:
	if $AnimationPlayer.current_animation == "swing" or $AnimationPlayer.current_animation == "second_swing" or $AnimationPlayer.current_animation == "bounce":
		hit_recovery = true

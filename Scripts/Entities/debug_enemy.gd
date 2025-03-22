extends CharacterBody3D
var player = null
var agro = false
var health = 10
var SPEED = 1
var rotation_speed = 0.03
var dead = false
var dmg_num = preload("res://Scenes/Entities/dmg_num.tscn")
var item_drop = preload("res://Scenes/Items/item_pickup.tscn")
var rot_dir = "left"
signal death

func _on_player_det_body_entered(body: Node3D) -> void:
	player = body
	agro = true
	
func turn():
	var global_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(player_pos.x,global_pos.y,player_pos.z),Vector3(0,1,0))
	var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), rotation_speed)
	global_transform = Transform3D(Basis(wrotation), global_transform.origin)

func _physics_process(delta: float) -> void:
	if player != null and agro == true and dead == false and not $AnimationPlayer.current_animation == "attack":
		var look_pos = player.position
		look_pos.y = self.position.y
		turn()
		if dead == false and not $AnimationPlayer.current_animation == "attack" and not $AnimationPlayer.current_animation == "bounceback" and global_position.distance_to(player.global_position) > 1.9 and global_position.distance_to(player.global_position) < 11:
			velocity = (((self.transform.basis) * Vector3(0, 0, -1)).normalized()) * SPEED
			move_and_slide()
		if $TestArea.overlaps_body(player) and not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("attack")
			%"Player Det".enabled = true
			%"Shield Det".enabled = true
	if %"Shield Det".is_colliding():
		bounceback()
	elif %"Player Det".is_colliding():
		%"Player Det".enabled = false
		%"Shield Det".enabled = false
		player.take_damage(7, "slash")

func bounceback():
	%"Player Det".enabled = false
	%"Shield Det".enabled = false
	$AnimationPlayer.play("bounceback")
	

func damage(x):
	agro = true
	if $AnimationPlayer.current_animation == "bounceback":
		health -= x * 1.5
	else:
		health -= x
	var dmg_num_active = dmg_num.instantiate()
	add_sibling(dmg_num_active)
	dmg_num_active.global_position = global_position
	dmg_num_active.global_position.y += 1.5
	if $AnimationPlayer.current_animation == "bounceback":
		dmg_num_active.show_text(x * 1.5)
	else:
		dmg_num_active.show_text(x)
	if health <= 0:
		dead = true
		$AnimationPlayer.play("death")


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "death":
		set_collision_layer_value(2, false)
		$CollisionShape3D.disabled = true
		%"Player Det".enabled = false
		%"Shield Det".enabled = false
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		item_drop = item_drop.instantiate()
		item_drop.global_position = self.global_position
		var item_visual = load("res://Assets/Models/rusted_knight/scene.gltf")
		item_visual = item_visual.instantiate()
		item_drop.add_child(item_visual)
		item_drop.item_visual = item_visual
		item_drop.item_id = load("res://Scripts/Inventory/debug_item.tres")
		get_tree().get_root().get_child(1).add_child(item_drop)
		death.emit()
		queue_free()

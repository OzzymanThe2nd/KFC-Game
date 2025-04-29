extends projectile

func _ready() -> void:
	rotation.x = 0
	rotation.y = 0
	rotation.z = 0
	player = get_parent_node_3d()
	top_level = true
	for i in range(1, 7):
		player = player.get_parent_node_3d()
	player = player.get_parent()
	dmg = dmg * (1 + Playerstatus.magic / 18)
	$MeshInstance3D/Area3D.body_entered.connect(_on_target_det_body_entered)

func projectile_damage(body):
	if body.has_method("damage"):
		body.damage(dmg)
		Playerstatus.skill_exp_gain("magic", dmg)
		body.player = player

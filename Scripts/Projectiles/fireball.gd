extends projectile

func _ready() -> void:
	rotation.x = 0
	rotation.y = 0
	rotation.z = 0
	player = Playerstatus.keepplayer
	top_level = true
	dmg = dmg * (1 + Playerstatus.magic / 18)
	$MeshInstance3D/Area3D.body_entered.connect(_on_target_det_body_entered)

func projectile_damage(body):
	if body.has_method("damage"):
		body.damage(dmg)
		Playerstatus.skill_exp_gain("magic", dmg)
		body.player = player

extends Node3D
const SPEED=0.19
var DOWN_VELOCITY = 0.01
var ROT_LEVEL = -0.01
var dmg=0
var player = null

func _ready() -> void:
	rotation.x = 0
	rotation.y = 0
	rotation.z = 0
	player = get_parent_node_3d()
	top_level = true
	for i in range(1, 7):
		player = player.get_parent_node_3d()
	player = player.get_parent()

func _physics_process(_delta: float) -> void:
	$MeshInstance3D.position += (Vector3.FORWARD * SPEED)
	$MeshInstance3D.position += (Vector3.DOWN * DOWN_VELOCITY)
	if not $MeshInstance3D.rotation_degrees.x <= -90:
		$MeshInstance3D.rotate_x(deg_to_rad(ROT_LEVEL))
	ROT_LEVEL -= 0.05
	DOWN_VELOCITY += (DOWN_VELOCITY/14)
	if self.position.distance_to($MeshInstance3D.position) > 100:
		queue_free()

func _on_target_det_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage(dmg)
		body.player = player
	queue_free()

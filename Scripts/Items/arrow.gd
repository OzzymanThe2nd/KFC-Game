extends Node3D
class_name projectile
@export var SPEED = 0.19
@export var DOWN_VELOCITY = 0.01
@export var DOWN_VELOCITY_INCREMENT = 14
@export var ROT_LEVEL = -0.01
@export var dmg = 0
@export var max_range = 100
var player = null

func _ready() -> void:
	rotation.x = 0
	rotation.y = 0
	rotation.z = 0
	player = Playerstatus.keepplayer
	top_level = true

func _physics_process(_delta: float) -> void:
	$MeshInstance3D.position += (Vector3.FORWARD * SPEED)
	$MeshInstance3D.position += (Vector3.DOWN * DOWN_VELOCITY)
	if not $MeshInstance3D.rotation_degrees.x <= -90:
		$MeshInstance3D.rotate_x(deg_to_rad(ROT_LEVEL))
	ROT_LEVEL -= 0.05
	DOWN_VELOCITY += (DOWN_VELOCITY/DOWN_VELOCITY_INCREMENT)
	if self.position.distance_to($MeshInstance3D.position) > max_range:
		queue_free()

func projectile_damage(body):
	if body.has_method("damage"):
		body.damage(dmg)
		Playerstatus.skill_exp_gain("archery", dmg)
		body.player = player

func _on_target_det_body_entered(body: Node3D) -> void:
	projectile_damage(body)
	queue_free()

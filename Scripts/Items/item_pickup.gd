extends Node3D
@export var item_visual : Node
@export var item_id : InvItem
var collected : bool = false

# Called when the node enters the scene tree for the first time.
func interact_with_player(player):
	if collected == false:
		collected = true
		player.collect(item_id)
		$Area3D.monitorable = false
		await get_tree().process_frame
		queue_free()

func _physics_process(delta: float) -> void:
	item_visual.rotation.y += deg_to_rad(1)

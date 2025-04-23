extends Node3D
@export var item_visual : Node
@export var item_id : InvItem
var collected : bool = false

# Called when the node enters the scene tree for the first time.
func interact_with_player(player):
	if collected == false:
		collected = true
		player.collect(item_id)
		await get_tree().process_frame
		$Area3D.set_collision_layer_value(1, false)
		visible = false
		play_pick_sound(item_id.soundtype)

func play_pick_sound(type = null):
	$PickSound.stream = load("res://Assets/Sounds/Inventory/Generic/GenericPickItem.wav")
	$PickSound.play()

func _physics_process(delta: float) -> void:
	item_visual.rotation.y += deg_to_rad(1)


func _on_pick_sound_finished() -> void:
	queue_free()

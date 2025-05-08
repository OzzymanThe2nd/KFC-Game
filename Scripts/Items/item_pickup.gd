extends Node3D
@export var item_visual : Node
@export var item_id : InvItem
var collected : bool = false
var interact_text
signal grabbed

func _ready() -> void:
	var button = str(InputMap.action_get_events("interact")[0].as_text()).split(" ")[0]
	interact_text = "%s: Grab" %[str(button)]

# Called when the node enters the scene tree for the first time.
func interact_with_player(player):
	if collected == false:
		collected = true
		player.collect(item_id)
		await get_tree().process_frame
		$Area3D.set_collision_layer_value(1, false)
		visible = false
		play_pick_sound(item_id.soundtype)
		emit_signal("grabbed")

func set_id(itempath):
	item_id = load(itempath)
	var new_item_visual = load(item_id.mesh).instantiate()
	add_child(new_item_visual)
	new_item_visual.scale.x = item_id.scale / 2
	new_item_visual.scale.y = item_id.scale / 2
	new_item_visual.scale.z = item_id.scale / 2
	new_item_visual.position.y = new_item_visual.position.y + item_id.y_off
	new_item_visual.rotation.x = item_id.rotate[0]
	new_item_visual.rotation.y = item_id.rotate[1]
	new_item_visual.rotation.z = item_id.rotate[2]
	item_visual = new_item_visual

func play_pick_sound(type = null):
	$PickSound.stream = load("res://Assets/Sounds/Inventory/Generic/GenericPickItem.wav")
	$PickSound.play()

func _physics_process(delta: float) -> void:
	if item_visual:
		item_visual.rotation.y += deg_to_rad(1)


func _on_pick_sound_finished() -> void:
	queue_free()

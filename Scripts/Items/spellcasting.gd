extends Node3D
var busy : bool = true
var currently_casting
signal spells_unequipped
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("pullout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func cast():
	pass

func put_away():
	if busy == false:
		busy = true
		$AnimationPlayer.play("unequip")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unequip":
		spells_unequipped.emit()
		queue_free()
	if anim_name == "pullout":
		busy = false

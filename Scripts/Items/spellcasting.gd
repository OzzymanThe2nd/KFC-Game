extends Node3D
var busy : bool = true
var currently_casting 
@onready var player = Playerstatus.keepplayer
#Scene path, mpcost, cast speed modifier
var dict_spellloader = {
	"fireball": ["res://Scenes/Projectiles/fireball.tscn", 8, 0.7],
	"heal": ["res://Scenes/Projectiles/heal.tscn", 12, 0.4]
}
signal spells_unequipped
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("pullout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func cast_main():
	currently_casting = Playerstatus.equipped_spells[0]
	if Playerstatus.magic_points >= (dict_spellloader[currently_casting])[1]:
		player.take_magic_points((dict_spellloader[currently_casting])[1])
		busy = true
		print(currently_casting)
		$AnimationPlayer.play("cast")
		$AnimationPlayer.speed_scale = (dict_spellloader[currently_casting])[2]

func cast_rmb():
	currently_casting = Playerstatus.equipped_spells[1]
	if Playerstatus.magic_points >= (dict_spellloader[currently_casting])[1]:
		player.take_magic_points((dict_spellloader[currently_casting])[1])
		busy = true
		print(currently_casting)
		$AnimationPlayer.play("cast")
		$AnimationPlayer.speed_scale = (dict_spellloader[currently_casting])[2]

func casting():
	$AnimationPlayer.play("return_cast")
	busy = true
	var SPELL = load((dict_spellloader[currently_casting])[0])
	SPELL = SPELL.instantiate()
	%SpellSpawn.add_child(SPELL)

func put_away():
	if busy == false:
		busy = true
		$AnimationPlayer.play("unequip")
		$AnimationPlayer.speed_scale = 1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unequip":
		spells_unequipped.emit()
		queue_free()
	if anim_name == "cast":
		casting()
	if anim_name == "pullout":
		busy = false
	if anim_name == "return_cast" and not $AnimationPlayer.is_playing():
		busy = false
		$AnimationPlayer.speed_scale = 1

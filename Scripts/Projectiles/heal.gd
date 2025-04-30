extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles3D.emitting = true

func _on_gpu_particles_3d_finished() -> void:
	Playerstatus.keepplayer.heal(8)
	queue_free()

extends Panel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$SubViewportContainer/SubViewport/MeshInstance3D.rotate_y(0.001)

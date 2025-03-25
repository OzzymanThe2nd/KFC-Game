extends Panel
var item : InvItem
var itemmesh
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready() -> void:
	if item:
		%ItemDescription.text = item.desc
		if item.mesh != "":
			itemmesh = load(item.mesh).instantiate() 
			%ModelSpot.add_child(itemmesh)
		else:
			$NinePatchRect/SubViewportContainer/SubViewport/ModelSpot/MeshInstance3D.visible = true
		if item.scale != 1:
			itemmesh.scale.x = item.scale
			itemmesh.scale.y = item.scale
			itemmesh.scale.z = item.scale
		%ModelSpot.position.x = item.x_off
		%ModelSpot.position.y = item.y_off
		%ModelSpot.position.z = item.z_off

func _process(delta: float) -> void:
	%ModelSpot.rotate_y(0.001)

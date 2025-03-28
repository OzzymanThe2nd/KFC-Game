extends Panel
var item : InvItem
var itemmesh
var dragmode = false
var in_mesh_drag = false
var mesh_drag = false
var in_drag_box = false
var start_pos_mouse
var start_pos_menu
var rot_x = 0
var rot_y = 0
var manual_rotate = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready() -> void:
	if item:
		%ItemName.text = str(item.name).capitalize()
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_click") and in_drag_box == true:
			start_pos_mouse = get_global_mouse_position()
			start_pos_menu = position
			dragmode = true
		if Input.is_action_pressed("left_click") and in_mesh_drag == true:
			mesh_drag = true
			manual_rotate = true
		if Input.is_action_just_released("left_click"):
			dragmode = false
			mesh_drag = false
	if event is InputEventMouseMotion:
		if mesh_drag == true:
			rot_x -= event.relative.x * 0.0035
			%ModelSpot.transform.basis = Basis()
			%ModelSpot.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			#if (rot_y - event.relative.y * 0.0035) < 1.3 and (rot_y - event.relative.y * 0.0035) > -1.3:
				#rot_y -= event.relative.y * 0.0035
			#%ModelSpot.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

func _process(delta: float) -> void:
	if manual_rotate == false:
		%ModelSpot.rotate_y(0.001)
	if dragmode == true:
		self.position = start_pos_menu + (get_global_mouse_position() - start_pos_mouse)


func _on_drag_det_mouse_entered() -> void:
	in_drag_box = true

func _on_drag_det_mouse_exited() -> void:
	in_drag_box = false

func _on_close_menu_pressed() -> void:
	queue_free()


func _on_mesh_drag_mouse_entered() -> void:
	in_mesh_drag = true


func _on_mesh_drag_mouse_exited() -> void:
	in_mesh_drag = false

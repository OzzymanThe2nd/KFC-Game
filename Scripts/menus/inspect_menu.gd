extends Panel
var item : InvItem
var itemmesh
var dragmode = false
var in_drag_box = false
var start_pos_mouse
var start_pos_menu
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
		elif Input.is_action_just_released("left_click"):
			dragmode = false

func _process(delta: float) -> void:
	%ModelSpot.rotate_y(0.001)
	if dragmode == true:
		self.position = start_pos_menu + (get_global_mouse_position() - start_pos_mouse)


func _on_drag_det_mouse_entered() -> void:
	in_drag_box = true

func _on_drag_det_mouse_exited() -> void:
	in_drag_box = false

func _on_close_menu_pressed() -> void:
	queue_free()

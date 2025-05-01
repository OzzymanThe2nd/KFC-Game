extends Control
var active : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open()


func open():
	get_tree().paused = true
	visible = true
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and get_tree().paused == true and active == true:
			await get_tree().process_frame
			close()

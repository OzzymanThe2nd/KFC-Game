extends Panel
var item : InvItem

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready() -> void:
	if item:
		%ItemDescription.text = item.desc
		%ModelSpot.add_child(load(item.mesh).instantiate())
		

func _process(delta: float) -> void:
	%ModelSpot.rotate_y(0.001)

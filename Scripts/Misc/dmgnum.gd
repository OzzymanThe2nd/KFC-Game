extends Node3D

func show_text(x):
	$Label3D.text = "%s" % str(x)
	
func _physics_process(delta: float) -> void:
	position.y += 0.015
#func _ready() -> void:
	#$Label3D.text = "%s" % str(displaynum)


func _on_timer_timeout() -> void:
	queue_free()

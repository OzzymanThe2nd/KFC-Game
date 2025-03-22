extends Control
var title = load("res://Scenes/Menus/title.tscn")


func _ready() -> void:
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	if conf != OK:
		config.set_value("Control", "crouchtoggle", false)
		config.set_value("Control", "mouse_sens", 0.0035)
		config.set_value("Control", "fov", 90)
		config.set_value("Sound", "vol", 100)
		config.set_value("Sound", "sfxvol", 100)
		config.save("user://settings.cfg")
	$CrouchToggle.button_pressed = config.get_value("Control","crouchtoggle")
	$Sens.value = config.get_value("Control","mouse_sens") * 10000
	$Fov.value = config.get_value("Control","fov")
	

func _process(delta: float) -> void:
	%"Fov Val".text = str($Fov.value)
	%"Sens Val".text = str($Sens.value)

func _on_button_pressed() -> void:
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	config.set_value("Control", "crouchtoggle", $CrouchToggle.button_pressed)
	config.set_value("Control", "mouse_sens", ($Sens.value / 10000))
	config.set_value("Control", "fov", $Fov.value)
	#config.set_value("Sound", "vol", 100)
	#config.set_value("Sound", "sfxvol", 100)
	config.save("user://settings.cfg")
	get_tree().change_scene_to_packed(title)

extends Panel
@export var is_equipment_slot : bool = false
@onready var right_click_menu_load = preload("res://Scenes/Menus/inv_right_click_menu.tscn")
@onready var tooltip_setting = preload("res://menu_font.tres")
@onready var item_icon : Sprite2D = $"CenterContainer/Panel/Item Sprite"
@onready var item_count : Label = $"CenterContainer/Panel/Item Count"
var mouse_inside : bool = false
var inside = null
var slot_keep = null
var right_click_menu = null
var rmb_menu_has_mouse = false
var sprite_follow : bool = false

func update(slot: invslot):
	if !slot:
		print("fucky wucky")
	elif !slot.item:
		item_icon.visible = false
		item_count.visible = false
		tooltip_text = ""
	else:
		slot_keep = slot
		inside = slot.item
		item_icon.visible = true
		item_icon.texture = slot.item.img
		if slot.amount > 1:
			item_count.visible = true
			item_count.text = "%s" % str(slot.amount)
		else:
			item_count.visible = false
		if slot.item.type == "weapon":
			var dmg
			if slot.item.name == "debug sword":
				dmg = 4
			tooltip_text = "%s\n%s\n%s" % [str(slot.item.name).capitalize(), str(slot.item.type).capitalize(), str(dmg)]
		else:
			tooltip_text = "%s \n%s" % [str(slot.item.name).capitalize(), str(slot.item.type).capitalize()]
		_make_custom_tooltip(tooltip_text)

func _make_custom_tooltip(for_text: String) -> Object:
	var label = Label.new()
	label.text = for_text
	label.label_settings = tooltip_setting
	return label

func _process(delta: float) -> void:
	if sprite_follow == true:
		$CenterContainer/Panel.position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("right_click"):
			if right_click_menu != null:
				right_click_menu.queue_free()
			if mouse_inside == true and right_click_menu == null and inside != null:
				right_click_menu = right_click_menu_load.instantiate()
				right_click_menu.get_player = true
				right_click_menu.get_inv = true
				right_click_menu.get_player_equipment = true
				add_child(right_click_menu)
				right_click_menu.item = inside
				right_click_menu.mouse_entered.connect(context_mouse_entered)
				right_click_menu.mouse_exited.connect(context_mouse_exited)
				right_click_menu.text_update()
				right_click_menu.position = get_viewport().get_mouse_position()
				rmb_menu_has_mouse = true
		if Input.is_action_just_pressed("left_click") and mouse_inside:
			sprite_follow = true
			$CenterContainer/Panel.top_level = true
			Playerstatus.swapping_item = slot_keep
		if Input.is_action_just_released("left_click"):
			sprite_follow = false
			$CenterContainer/Panel.position.y = 100
			$CenterContainer/Panel.position.x = 100
			$CenterContainer/Panel.top_level = false



func context_mouse_entered():
	rmb_menu_has_mouse = true
	
func context_mouse_exited():
	rmb_menu_has_mouse = false
	for i in 6:
		await get_tree().process_frame
	if right_click_menu != null and mouse_inside == false:
		right_click_menu.queue_free()

func _on_mouse_exited() -> void:
	mouse_inside = false
	for i in 6:
		await get_tree().process_frame
	if right_click_menu != null and rmb_menu_has_mouse == false:
		right_click_menu.queue_free()

func _on_mouse_entered() -> void:
	mouse_inside = true

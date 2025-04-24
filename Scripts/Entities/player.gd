extends CharacterBody3D
@export var resetinven : bool
@export var passive_glow : bool
@export var doublejump_able : bool
@export var godmode : bool
@onready var inventory = load("res://Scripts/Inventory/player_inven.tres")
@onready var equipment = load("res://Scripts/Inventory/player_equipped.tres")
@onready var maingame = self.get_parent_node_3d()
var stored_level
var stored_coord
var loadSWORD
var loadSHIELD
var loadBOW
var footstep_val : float = 30
var footstep_sounds_metal = ["res://Assets/Sounds/FootstepMetal1.wav","res://Assets/Sounds/FootstepMetal2.wav","res://Assets/Sounds/FootstepMetal3.wav","res://Assets/Sounds/FootstepMetal4.wav"]
@onready var debug_item_spawn = preload("res://Scripts/Inventory/debug_item.tres")
var weapononright = true
var weaponbounceup = true
var swordswingable = false
var SWORD = null
var SHIELD = null
var BOW = null
var swordout = false
var steptype : String = "metal"
var stepqueued : bool = false
const SPEED = 3.5
const SPRINTSPEED = 7.0
const CROUCHSPEED = 2.0
const JUMP_VELOCITY = 3.5
const MAX_STEP_HEIGHT = 0.5
var snapped_to_stairs = false
var mouse_sens = 0.0035
var rot_x = 0
var rot_y = 0
var crouch = false
var crouchtoggle = true
var camerapos = null
var basefov = null
var zoomfov = null
var shieldblocking = false
var bow_equip_queued = false
var sword_equip_queued = false
var shield_equip_queued = false
@onready var checkpoint = self.global_position
var doublejump_free = true
@onready var magtext = %magtext

@warning_ignore("unused_signal")
signal dead
@warning_ignore("unused_signal")
signal levelend
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if godmode == true:
		Playerstatus.healthmax = INF
		Playerstatus.healthcurrent = INF
	#if resetinven == true:
		#Inven.itemsheld = []
	if passive_glow == false:
		$OmniLight3D.visible = false
	var config = ConfigFile.new()
	var conf = config.load("user://settings.cfg")
	if conf != OK:
		config.set_value("Control", "crouchtoggle", false)
		config.set_value("Control", "mouse_sens", 0.0035)
		config.set_value("Control", "fov", 90)
		config.set_value("Sound", "vol", 100)
		config.set_value("Sound", "sfxvol", 100)
		config.save("user://settings.cfg")
	crouchtoggle = config.get_value("Control","crouchtoggle")
	mouse_sens = config.get_value("Control","mouse_sens")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	basefov = config.get_value("Control","fov")
	zoomfov = basefov * 0.7
	var volpercent = config.get_value("Sound","vol")
	var sfxvolpercent = config.get_value("Sound","sfxvol")
	var busid = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(busid,linear_to_db(volpercent/100))
	%PCamera.fov = basefov
	%heltext.text = "%s" % str(Playerstatus.healthcurrent)
	%Bobbloid.play("wobble")
	%Bobbloid.pause()
	$CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_entered.connect(_on_interact_window_detect_body_entered)
	$CamNode3D/CamSmooth/PCamera/InteractWindowDetect.area_exited.connect(_on_interact_window_detect_body_exited)
	if Playerstatus.loading_new_game == true:
		equipment = load("res://Scripts/Inventory/player_new_game_equipment.tres")
		inventory = load("res://Scripts/Inventory/player_new_game_inven.tres")
		Playerstatus.chest_inven = load("res://Scripts/Inventory/chest_new_game_inventory.tres")
		Playerstatus.temp_equip = equipment
		Playerstatus.temp_inven = inventory
	update_status()
	check_warp()
	await get_tree().process_frame
	self.transform.basis = Basis()
	self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
	%PCamera.transform.basis = Basis() # reset rotation
	%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	Playerstatus.loading_image_clear()

func is_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func camera_stair_smoothing():
	if camerapos == null:
		camerapos = %CamSmooth.global_position
		
func slide_cam_back(delta):
	if camerapos == null:
		return
	%CamSmooth.global_position.y = camerapos.y
	%CamSmooth.position.y = clampf(%CamSmooth.position.y, -0.55,0.55)
	var moveamount = max(self.velocity.length() * delta, SPEED/2 * delta)
	%CamSmooth.position.y = move_toward(%CamSmooth.position.y,0.0, moveamount)
	camerapos = %CamSmooth.global_position
	if %CamSmooth.position.y == 0:
		camerapos = null
	
func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not snapped_to_stairs: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairsForward.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairsForward.force_raycast_update()
		if %StairsForward.is_colliding() and not is_too_steep(%StairsForward.get_collision_normal()):
			camera_stair_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			snapped_to_stairs = true
			return true
	return false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		stepqueued = true
	#!Sprint/Dash code: only one at a time, decide what you'd prefer later
	#var sprint = Input.is_action_pressed("move_sprint")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forw", "move_back")
	var direction = ((self.transform.basis) * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if crouch == true:
			velocity.x = direction.x * CROUCHSPEED
			velocity.z = direction.z * CROUCHSPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED-2.5)
		velocity.z = move_toward(velocity.z, 0, SPEED-2.5)
		footstep_val = 6
	#if Input.is_action_just_pressed("flashlight"): #Flashlight stuff
		#if smgready==true:
			#SMG.flashlight()
	if Input.is_action_just_pressed("move_crouch"): #Crouch stuff
		if crouch == false:
			%PlayerAnim.play("crouch")
			crouch = true
		elif crouch == true and crouchtoggle == true:
			%PlayerAnim.play("uncrouch")
			crouch = false
	if Input.is_action_just_released("move_crouch") and crouchtoggle == false:
		if crouch == true:
			%PlayerAnim.play("uncrouch")
			crouch = false
	if Input.is_action_pressed("zoom"):
		if SHIELD != null:
			if SHIELD.busy == false and swordout == false and shieldblocking == false:
				SHIELD.block()
				shieldblocking = true
	if Input.is_action_just_released("zoom"):
		if SHIELD != null:
			if SHIELD.busy == false:
				SHIELD.stopblocking = true
	if Input.is_action_pressed("shoot"):
		if swordswingable == true:
			swordswing()
		else:
			bowshoot()
	if is_on_floor():
		if stepqueued:
			footstep()
			stepqueued = false
		doublejump_free = true
		if velocity.x != 0 or velocity.z != 0:
			footstep_val -= 1
			if footstep_val <= 0:
				footstep()
	weaponbobble()
	if not _snap_up_stairs_check(delta):
		move_and_slide()
	slide_cam_back(delta)

func footstep():
	if steptype == "metal":
		$Footstep.stream = load(footstep_sounds_metal[randi_range(0,3)])
	$Footstep.play()
	footstep_val = 30

func show_text(text: String, show_time : float):
	if not $HudAnim.is_playing():
		%PopUpText.text = text
		$CamNode3D/CanvasLayer/PopUpText/PopUpTimer.wait_time = show_time + 0.3
		$CamNode3D/CanvasLayer/PopUpText/PopUpTimer.start()
		$HudAnim.play("TextPopUp")

func _input(event):
	if event is InputEventMouseMotion:
		rot_x -= event.relative.x * mouse_sens
		self.transform.basis = Basis()
		self.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		if (rot_y - event.relative.y * mouse_sens) < 1.3 and (rot_y - event.relative.y * mouse_sens) > -1.3:
			rot_y -= event.relative.y * mouse_sens
		%PCamera.transform.basis = Basis() # reset rotation
		%PCamera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

	if event is InputEventKey:
		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			checkpoint = self.global_position
		if Input.is_action_just_pressed("move_jump") and not is_on_floor() and doublejump_free == true and doublejump_able == true:
			velocity.y = JUMP_VELOCITY
			doublejump_free = false
		if Input.is_action_just_pressed("0"):
			unequip_all()
		elif Input.is_action_just_pressed("1"):
			equipsword()
		elif Input.is_action_just_pressed("2"):
			equipshield()
		elif Input.is_action_just_pressed("3"):
			equipbow()
		elif Input.is_action_just_pressed("4"):
			Playerstatus.exp_gain(15)
		elif Input.is_action_just_pressed("f5"):
			Playerstatus.save_all(self)
		elif Input.is_action_just_pressed("f9"):
			Playerstatus.load_game()
		if Input.is_action_just_pressed("interact"):
			if %Interact.is_colliding(): 
				var body = (%Interact.get_collider()).get_parent()
				if body.has_method("interact"):
					body.interact()
				elif body.has_method("interact_with_player"):
					body.interact_with_player(self)

func equipsword():
	if BOW != null:
		bow_unequip()
		sword_equip_queued = true
	if SWORD == null and BOW == null and loadSWORD != null:
		SWORD = loadSWORD.instantiate()
		SWORD.sword_unequipped.connect(_on_sword_unequipped)
		%SwordBobbleLoc.add_child(SWORD)
		swordswingable = true
	elif SWORD != null:
		if SWORD.busy == false:
			sword_unequip()

func bowshoot():
	if BOW != null:
		if BOW.busy != true:
			if equipment.slots[7].amount != 0:
				equipment.slots[7].amount -= 1
				if equipment.slots[7].amount >= 0:
					equipment.slots[7].item = null
				BOW.shoot()

func equipshield():
	if BOW != null:
		bow_unequip()
		shield_equip_queued = true
	if SHIELD == null and BOW == null and loadSHIELD != null:
		SHIELD = loadSHIELD.instantiate()
		SHIELD.shield_unequipped.connect(_on_shield_unequipped)
		%ShieldBobbleLoc.add_child(SHIELD)
	elif SHIELD != null:
		if SHIELD.busy == false:
			shield_unequip()

func equipbow():
	if SHIELD != null or SWORD != null:
		unequip_all()
		bow_equip_queued = true
	if BOW == null and SHIELD == null and SWORD == null and loadBOW != null:
		BOW = loadBOW.instantiate()
		BOW.bow_unequipped.connect(_on_bow_unequipped)
		%BowBobble.add_child(BOW)
	elif BOW != null:
		if BOW.busy == false:
			bow_unequip()

func unequip_all():
	if SWORD != null:
		sword_unequip()
	if SHIELD != null:
		shield_unequip()

func save():
	var save_dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : "level",
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rot_x,
		"rot_y" : rot_y,
		"process_mode" : process_mode
	}
	return save_dictionary

func game_over():
	emit_signal("dead")

func weaponbobble():
	if velocity.x != 0 or velocity.z != 0:
		%Bobbloid.play()
	else:
		%Bobbloid.pause()

func take_magic_points(x):
	if Playerstatus.magic_points - x <= 0:
		Playerstatus.magic_points = 0
	else:
		Playerstatus.magic_points -= x

func gain_magic_points(x):
	if Playerstatus.magic_points + x >= Playerstatus.base_magic_points:
		Playerstatus.magic_points = Playerstatus.base_magic_points
	else:
		Playerstatus.magic_points += x

func take_damage(x,type):
	if type == "slash":
		if roundi(x*(0.9**Playerstatus.protslash)) >= 0:
			Playerstatus.healthcurrent -= roundi(x*(0.95**Playerstatus.protslash))
		else: pass
	elif type == "crush":
		if roundi(x*(0.9**Playerstatus.protcrush)) >= 0:
			Playerstatus.healthcurrent -= roundi(x*(0.95**Playerstatus.protcrush))
		else: pass
	elif type == "stab":
		if roundi(x*(0.9**Playerstatus.protstab)) >= 0:
			Playerstatus.healthcurrent -= roundi(x*(0.95**Playerstatus.protstab))
		else: pass
	else: Playerstatus.healthcurrent -= x
	%heltext.text = "%s" % str(Playerstatus.healthcurrent)
	%Hbar.value = Playerstatus.healthcurrent
	%HealthAnims.play("HP bar shake")
	if Playerstatus.healthcurrent <= 0:
		Playerstatus.healthcurrent = 0
		%heltext.text = "%s" % str(Playerstatus.healthcurrent)
		game_over()

func pitfall():
	take_damage(10, "")
	global_position = checkpoint

func hud_pixelate(on : bool = false):
	if on == true:
		$"CamNode3D/CanvasLayer/Pixelate Hud".visible = true
	else:
		$"CamNode3D/CanvasLayer/Pixelate Hud".visible = false

func pixelate_off():
	%Pixelate.visible = false

func show_hud(on : bool = false):
	var hud_elements = [$CamNode3D/CanvasLayer/Health]
	if on == true:
		for i in hud_elements:
			i.visible = true
	else:
		for i in hud_elements:
			i.visible = false
	

func travel_with_fade(level, coord):
	stored_level = level
	stored_coord = coord
	$HudAnim.play("FadeToBlack")

func heal(x):
	if (Playerstatus.healthcurrent + x) >= Playerstatus.healthmax:
		Playerstatus.healthcurrent = Playerstatus.healthmax
	else:
		Playerstatus.healthcurrent += x
	%heltext.text = "%s" % str(Playerstatus.healthcurrent)
	%Hbar.value = Playerstatus.healthcurrent
	
func overheal(x):
	Playerstatus.healthcurrent += x
	%heltext.text = "%s" % str(Playerstatus.healthcurrent)
	if Playerstatus.healthcurrent >= Playerstatus.healthmax:
		%Hbar.value = Playerstatus.healthmax
	else:
		%Hbar.value = Playerstatus.healthcurrent

func sword_unequip():
	if SWORD.busy == false:
		SWORD.putaway()
		swordswingable = false
	%magtext.text = ""
	%ammotext.text = ""
	
func shield_unequip():
	if SHIELD.busy == false:
		SHIELD.putaway()

func bow_unequip():
	if BOW.busy == false:
		BOW.putaway()

func swordswing():
	if swordout == false and swordswingable == true and SWORD.busy==false and not shieldblocking==true:
		swordout = true
		SWORD.swing()
	elif SWORD.second_swing_possible == true:
		SWORD.second_swing()

func endlevel():
	%LevelEnd.visible = true
	%PlayerAnim.play("FadeToBlack")

func _on_player_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeToBlack":
		emit_signal("levelend")

func pixelatetoggle():
	if %Pixelate.visible == true:
		%Pixelate.visible = false
	elif %Pixelate.visible == false:
		%Pixelate.visible = true

func glowtoggle(x):
	if x == null:
		if $OmniLight3D.visible == true:
			$OmniLight3D.visible = false
		elif $OmniLight3D.visible == false:
			$OmniLight3D.visible = true
	elif x == true:
		$OmniLight3D.visible = true
	elif x == false:
		$OmniLight3D.visible = false
		
func equip_queued():
	if sword_equip_queued == true:
		equipsword()
		sword_equip_queued = false
	if shield_equip_queued == true:
		equipshield()
		shield_equip_queued = false
	if bow_equip_queued == true:
		equipbow()
		bow_equip_queued = false

func update_status():
	var helmet = equipment.slots[0].item
	var chest = equipment.slots[1].item
	var gloves = equipment.slots[2].item
	var legs = equipment.slots[3].item
	var weapon = equipment.slots[4].item
	var shield = equipment.slots[5].item
	var bow = equipment.slots[6].item
	var arrow = equipment.slots[7].item
	%Hbar.max_value = Playerstatus.healthmax
	%Hbar.value = Playerstatus.healthcurrent
	Playerstatus.update_stats(self, helmet, chest, gloves, legs, weapon, shield, bow, arrow)

func check_warp():
	if Playerstatus.warp_to != null:
		self.global_position = Playerstatus.warp_to
		Playerstatus.warp_to = null
	if Playerstatus.store_equip != null:
		Playerstatus.store_equip = null
	if Playerstatus.store_inven != null:
		Playerstatus.store_inven = null

func _on_sword_spawn_child_exiting_tree(_node: Node) -> void:
	swordout = false

func _on_sword_unequipped():
	SWORD.queue_free()
	await get_tree().process_frame
	equip_queued()

func _on_shield_unequipped():
	SHIELD.queue_free()
	await get_tree().process_frame
	equip_queued()

func collect(item):
	inventory.insert(item)

func use_item(item):
	if item == "debug":
		overheal(100)

func _on_bow_unequipped():
	BOW.queue_free()
	await get_tree().process_frame
	equip_queued()


func _on_hud_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeToBlack":
		Playerstatus.level_change(stored_level, stored_coord)
		get_parent().queue_free()


func _on_pop_up_timer_timeout() -> void:
	if $HudAnim.is_playing() == false:
		$HudAnim.play("TextFadeAway")


func _on_interact_window_detect_body_entered(body: Node3D) -> void:
	body = body.get_parent()
	if body.has_method("interact") or body.has_method("interact_with_player"):
		%InteractPrompt.visible = true
		if "interact_text" in body:
			var new_text = body.interact_text
			$CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = new_text
		else:
			var button
			button = str(InputMap.action_get_events("interact")[0].as_text()).split(" ")[0]
			$CamNode3D/CanvasLayer/InteractPrompt/InteractText.text = "%s: Interact" %[str(button)]


func _on_interact_window_detect_body_exited(body: Node3D) -> void:
	body = body.get_parent()
	if body.has_method("interact") or body.has_method("interact_with_player"):
		%InteractPrompt.visible = false

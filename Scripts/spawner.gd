extends Area3D
var spawners = []
var spawned_enemies = 0
var enemyLOAD = preload("res://Scenes/Entities/debug_enemy.tscn")
var player = null
var enemies_list = []
@export var despawn_distance : int
@export var spawned_at_once : int
@export var spawn_cap : int

func _ready() -> void:
	var kids = get_children()
	for i in kids:
		if i.is_in_group("spawner"):
			spawners.append(i)
			
			

func _on_body_entered(body: Node3D) -> void:
	for i in enemies_list:
		if not is_instance_valid(i):
			enemies_list.erase(i)
	if enemies_list.size() == 0:
		spawned_enemies = 0
	player = body
	if $Timer.is_stopped():
		$Timer.start()
	if spawned_enemies < spawn_cap:
		var relevant_spawns = spawners.duplicate(true)
		for i in range (0,spawned_at_once):
			var activespawner = relevant_spawns.pick_random()
			relevant_spawns.erase(activespawner)
			var enemy = enemyLOAD.instantiate()
			self.add_child(enemy)
			enemy.add_to_group("Reset_On_Load")
			enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
			enemies_list.append(enemy)
			enemy.death.connect(_on_enemy_death)
			spawned_enemies += 1
			enemy.position = activespawner.position
			
func _on_enemy_death():
	spawned_enemies -= 1
	enemies_list.remove_at(0)


func _on_timer_timeout() -> void:
	if enemies_list.size() > 0 and player != null:
		if player.position.distance_to(self.position) >= despawn_distance:
			for i in enemies_list:
				if i.position.distance_to(player.position) > 5:
					enemies_list.erase(i)
					i.queue_free()
	if player == null:
		for i in enemies_list:
			enemies_list.erase(i)
	elif enemies_list.size() == 0:
		$Timer.stop()
		spawned_enemies = 0

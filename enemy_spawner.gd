extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_distance: float = 800.0
@export var enemy_num: int = 20
@export var enemy_timer: float = 1.0
@export var sprite_variants: Array[Texture2D] = []

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
var enemies_made: int = 0

func _ready():
	enemy_spawn_timer.timeout.connect(spawn_enemy)
	enemy_spawn_timer.wait_time = enemy_timer
	enemy_spawn_timer.start() # Ensure your timer is running

func spawn_enemy():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# 1. Spawning phase: Keep spawning until we hit the target number
	if enemies_made < enemy_num:
		var enemy = enemy_scene.instantiate()

		var angle = randf_range(0.0, TAU)
		var spawn_offset = Vector2(cos(angle), sin(angle)) * spawn_distance
		enemy.global_position = player.global_position + spawn_offset

		if sprite_variants.size() > 0 and enemy.has_method("set_texture"):
			enemy.set_texture(sprite_variants[enemies_made % sprite_variants.size()])

		add_child(enemy)
		enemies_made += 1
	
	# 2. Waiting phase: Stop the timer, wait until all enemies are dead
	else:
		enemy_spawn_timer.stop() # Stop ticking rapidly
		check_level_completion()

func check_level_completion():
	var active_enemies = get_tree().get_nodes_in_group("enemies")

	if active_enemies.size() == 0:
		var ability_manager = get_tree().get_first_node_in_group("ability_manager")
		if ability_manager:
			ability_manager.show_cards()
		else:
			get_tree().get_first_node_in_group("scene_manager").increase_level()
	else:
		get_tree().create_timer(1.0).timeout.connect(check_level_completion)

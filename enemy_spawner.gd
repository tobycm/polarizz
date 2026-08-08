extends Node2D
@export var enemy_scene: PackedScene
@export var spawn_distance: float = 800.0
@export var enemy_num:int =20
@export var enemy_timer:float =1

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
var enemies_made:int = 0


func _ready():
	enemy_spawn_timer.timeout.connect(spawn_enemy)
	enemy_spawn_timer.wait_time=enemy_timer

func spawn_enemy():
	
	var player = get_tree().get_first_node_in_group("player")

	if player == null or enemy_num<enemies_made:
		print(enemies_made)
		return

	var enemy = enemy_scene.instantiate()

	var angle = randf_range(0.0, TAU)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * spawn_distance

	enemy.global_position = player.global_position + spawn_offset

	add_child(enemy)
	enemies_made+=1

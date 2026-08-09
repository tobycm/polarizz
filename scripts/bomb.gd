extends Node2D

const TNT_FRAME_TIME := 0.35
const EXPLOSION_FRAME_TIME := 0.12
const EXPLOSION_RADIUS := 240.0

@export var tnt_frames: Array[Texture2D] = []
@export var explosion_frames: Array[Texture2D] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


func _ready() -> void:
	_play_fuse()


func _play_fuse() -> void:
	for frame in tnt_frames:
		sprite.texture = frame
		await get_tree().create_timer(TNT_FRAME_TIME).timeout

		if not is_instance_valid(self):
			return

	_explode()


func _explode() -> void:
	ScreenShake.shake(14.0, 0.35)
	explosion_sound.play()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue

		if enemy.global_position.distance_to(global_position) <= EXPLOSION_RADIUS:
			if enemy.has_method("_die"):
				enemy._die()
			else:
				enemy.queue_free()

	for frame in explosion_frames:
		sprite.texture = frame
		await get_tree().create_timer(EXPLOSION_FRAME_TIME).timeout

		if not is_instance_valid(self):
			return

	if explosion_sound.playing:
		await explosion_sound.finished

	queue_free()

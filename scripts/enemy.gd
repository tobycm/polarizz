extends CharacterBody2D

@export var speed: float = 100.0
@export var hit_points: int = 1
@export var zap_frame_time: float = 0.35

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var static_sprite: Sprite2D = get_node_or_null("Sprite2D")

var target: Node2D
var zap_texture_1: Texture2D
var zap_texture_2: Texture2D
var is_dying := false

func _ready():
	add_to_group("enemies")

	if animated_sprite:
		animated_sprite.play("walk")
	target = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if is_dying:
		return

	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return

	var direction = global_position.direction_to(target.global_position)
	velocity = direction * speed

	if velocity.x != 0:
		if animated_sprite:
			animated_sprite.flip_h = velocity.x < 0
		elif static_sprite:
			static_sprite.flip_h = velocity.x < 0

	move_and_slide()


func set_texture(texture: Texture2D) -> void:
	if static_sprite:
		static_sprite.texture = texture


func set_zap_frames(frame_1: Texture2D, frame_2: Texture2D) -> void:
	zap_texture_1 = frame_1
	zap_texture_2 = frame_2


func _die() -> void:
	if is_dying:
		return

	is_dying = true
	remove_from_group("enemies")
	velocity = Vector2.ZERO

	if static_sprite and zap_texture_1 and zap_texture_2:
		static_sprite.texture = zap_texture_1
		await get_tree().create_timer(zap_frame_time).timeout

		if not is_instance_valid(self):
			return

		static_sprite.texture = zap_texture_2
		await get_tree().create_timer(zap_frame_time).timeout

		if not is_instance_valid(self):
			return

	queue_free()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		if is_dying or not body.is_in_group("zapper"):
			return

		hit_points -= 1

		if hit_points <= 0:
			_die()

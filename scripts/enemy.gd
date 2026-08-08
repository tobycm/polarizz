extends CharacterBody2D

@export var speed: float = 100.0
@export var hit_points: int = 1

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var static_sprite: Sprite2D = get_node_or_null("Sprite2D")

var target: Node2D

func _ready():
	add_to_group("enemies")

	if animated_sprite:
		animated_sprite.play("walk")
	target = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
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





func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		hit_points -= 1

		if hit_points <= 0:
			queue_free()

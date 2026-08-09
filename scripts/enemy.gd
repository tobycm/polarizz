extends CharacterBody2D

@export var speed: float = 50.0
@export var hit_points: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var target: Node2D
var is_dying := false


func _ready() -> void:
	add_to_group("enemies")

	animated_sprite.play("walk")

	target = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if is_dying:
		return

	# Find the player if we don't currently have one
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")

		if target == null:
			return

	# Move toward the player
	var direction := global_position.direction_to(target.global_position)
	velocity = direction * speed

	# Flip sprite depending on direction
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

	move_and_slide()


func _die() -> void:
	if is_dying:
		return

	is_dying = true
	remove_from_group("enemies")
	velocity = Vector2.ZERO

	Global.add_kill_score()

	# Stop movement and play zap animation
	animated_sprite.play("zap")

	# Wait until the zap animation finishes
	await animated_sprite.animation_finished
	print("zapidy zapdy zap zap")
	# Delete enemy
	queue_free()


func _on_area_2d_body_shape_entered(
	body_rid: RID,
	body: Node2D,
	body_shape_index: int,
	local_shape_index: int
) -> void:

	if is_dying:
		return

	if not body.is_in_group("zapper"):
		return

	hit_points -= 1

	if hit_points <= 0:
		_die()

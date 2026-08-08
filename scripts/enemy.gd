extends CharacterBody2D

@export var speed: float = 100.0

var target: Node2D

func _ready():
	add_to_group("enemies")

	$AnimatedSprite2D.play("walk")
	target = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return

	var direction = global_position.direction_to(target.global_position)
	velocity = direction * speed

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	move_and_slide()





func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		queue_free()

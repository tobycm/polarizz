extends CharacterBody2D
@onready var zapper: StaticBody2D = $"../zapper"

const SPEED := 300.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down"
	)

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	zapper.addPoint(body.global_position)

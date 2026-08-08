extends CharacterBody2D

@onready var zapper: StaticBody2D = $"../zapper"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var line: Line2D = $Line2D
@onready var line_collision: CollisionShape2D = $Line2D/Area2D/CollisionShape2D

const MOVE_SPEED := 430.0

const DASH_SPEED := 900.0
const DASH_TIME := 0.08
const DASH_COOLDOWN := 0.14

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_dir := Vector2.RIGHT
var last_input_dir := Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")
	line.top_level = true
	
	line_collision.shape.a=global_position

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	line.set_point_position(0, global_position)
	line_collision.shape.a=global_position
	

	if input_dir != Vector2.ZERO:
		last_input_dir = input_dir

	# Dash input
	if Input.is_action_just_pressed("ui_accept") and dash_cooldown_timer <= 0.0:
		dash_dir = last_input_dir
		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_COOLDOWN

	# Timers
	if dash_timer > 0.0:
		dash_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	# Sharp movement: direct velocity set, no acceleration
	if dash_timer > 0.0:
		velocity = dash_dir * DASH_SPEED
	else:
		velocity = input_dir * MOVE_SPEED

	move_and_slide()

	# Animation
	if velocity.length() > 10.0:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = clamp(velocity.length() / MOVE_SPEED * 1.2, 1.0, 2.0)
	else:
		animated_sprite_2d.play("stand")
		animated_sprite_2d.speed_scale = 1.0

	if velocity.x != 0.0:
		animated_sprite_2d.flip_h = velocity.x > 0

func reset() -> void:
	line.clear_points()
	line.add_point(global_position)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.a = global_position
		line_collision.shape.b = global_position
		
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if !body.disabled:
		if line.get_point_count() < 2:
			if line.get_point_count() == 0:
				line.add_point(global_position)
			else:
				line.set_point_position(0, global_position)
	
			line.add_point(body.global_position, 1)
		line_collision.shape.b=body.global_position
		line.set_point_position(1, body.global_position)
		print("enter" + str(body))
		zapper.addPoint(body.global_position, body)

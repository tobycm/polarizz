extends CharacterBody2D

@onready var zapper: StaticBody2D = $"../zapper"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const MAX_SPEED := 320.0
const ACCEL := 2200.0
const FRICTION := 2600.0

const DASH_SPEED := 620.0
const DASH_TIME := 0.10
const DASH_COOLDOWN := 0.18
@onready var line: Line2D = $Line2D

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_dir := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	line.top_level = true   
	if line.get_point_count() == 0:
		line.add_point(global_position)
	else:
		line.set_point_position(0, global_position)
	
	
func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	line.set_point_position(0, global_position)

	if Input.is_action_just_pressed("ui_accept") and dash_cooldown_timer <= 0.0:
		if input_dir != Vector2.ZERO:
			dash_dir = input_dir
		elif velocity != Vector2.ZERO:
			dash_dir = velocity.normalized()
		else:
			dash_dir = Vector2.RIGHT

		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_COOLDOWN

	if dash_timer > 0.0:
		dash_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if dash_timer > 0.0:
		velocity = dash_dir * DASH_SPEED
	else:
		var target_velocity := input_dir * MAX_SPEED

		if input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(target_velocity, ACCEL * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	if velocity.length() > 20.0:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = clamp(velocity.length() / MAX_SPEED * 1.35, 0.9, 1.8)
	else:
		animated_sprite_2d.play("stand")
		animated_sprite_2d.speed_scale = 1.0

	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0

func _on_area_2d_body_shape_entered(
	body_rid: RID,
	body: Node2D,
	body_shape_index: int,
	local_shape_index: int
) -> void:
	if line.get_point_count()<2:
		line.add_point(body.global_position,1)
	line.set_point_position(1, body.global_position)

	zapper.addPoint(body)

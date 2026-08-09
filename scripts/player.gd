extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var line: Line2D = $Line2D
@onready var line_collision: CollisionShape2D = $Line2D/Area2D/CollisionShape2D

const BASE_MOVE_SPEED := 430.0

const DASH_SPEED := 900.0
const DASH_TIME := 0.08
const DASH_COOLDOWN := 2.0

const DASH_GHOST_FADE_TIME := 0.25
const DASH_GHOST_COLOR := Color(0.6, 0.85, 1.0, 0.5)

const MAX_LIVES := 3

const BOMB_SCENE := preload("res://scenes/effects/bomb.tscn")
const BOMB_COOLDOWN := 10.0

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_dir := Vector2.RIGHT
var last_input_dir := Vector2.RIGHT
var speed_multiplier := 1.0
var bombs := 0
var bomb_cooldown_timer := 0.0
var zapper
var lives := MAX_LIVES
var is_dead := false
var spawn_position: Vector2

func _ready() -> void:
	add_to_group("player")
	zapper = get_tree().get_first_node_in_group("zapper")
	spawn_position = global_position

	line.top_level = true

	line.clear_points()
	line.add_point(global_position)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.a = global_position
		line_collision.shape.b = global_position


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	zapper = get_tree().get_first_node_in_group("zapper")
	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	).normalized()

	var move_speed = BASE_MOVE_SPEED * speed_multiplier


	# =====================================================
	# MAKE SURE LINE ALWAYS HAS POINT 0
	# =====================================================

	if line.get_point_count() == 0:
		line.add_point(global_position)

	line.set_point_position(0, global_position)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.a = global_position


	# =====================================================
	# REMEMBER LAST MOVEMENT DIRECTION
	# =====================================================

	if input_dir != Vector2.ZERO:
		last_input_dir = input_dir


	# =====================================================
	# DASH
	# =====================================================

	if Input.is_action_just_pressed("dash") \
			and dash_cooldown_timer <= 0.0:

		dash_dir = last_input_dir
		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_COOLDOWN


	# =====================================================
	# BOMB
	# =====================================================

	if Input.is_action_just_pressed("bomb") \
			and bomb_cooldown_timer <= 0.0 \
			and bombs > 0:

		_throw_bomb()
		bombs -= 1
		bomb_cooldown_timer = BOMB_COOLDOWN


	# =====================================================
	# TIMERS
	# =====================================================

	if dash_timer > 0.0:
		dash_timer -= delta

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if bomb_cooldown_timer > 0.0:
		bomb_cooldown_timer -= delta


	# =====================================================
	# MOVEMENT
	# =====================================================

	if dash_timer > 0.0:
		velocity = dash_dir * DASH_SPEED
		_spawn_dash_ghost()
	else:
		velocity = input_dir * move_speed

	move_and_slide()


	# =====================================================
	# UPDATE LINE AFTER MOVEMENT
	# =====================================================

	if line.get_point_count() == 0:
		line.add_point(global_position)

	line.set_point_position(0, global_position)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.a = global_position


	# =====================================================
	# ANIMATION
	# =====================================================

	if velocity.length() > 10.0:
		animated_sprite_2d.play("walk")

		animated_sprite_2d.speed_scale = clamp(
			velocity.length() / move_speed * 1.2,
			1.0,
			2.0
		)
	else:
		animated_sprite_2d.play("stand")
		animated_sprite_2d.speed_scale = 1.0

	if velocity.x != 0.0:
		animated_sprite_2d.flip_h = velocity.x > 0


# =========================================================
# DASH TRAIL
# =========================================================

func _spawn_dash_ghost() -> void:
	var frames := animated_sprite_2d.sprite_frames
	if frames == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = frames.get_frame_texture(animated_sprite_2d.animation, animated_sprite_2d.frame)
	ghost.global_position = animated_sprite_2d.global_position
	ghost.global_rotation = animated_sprite_2d.global_rotation
	ghost.global_scale = animated_sprite_2d.global_scale
	ghost.flip_h = animated_sprite_2d.flip_h
	ghost.modulate = DASH_GHOST_COLOR
	ghost.z_index = z_index - 1

	get_parent().add_child(ghost)

	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, DASH_GHOST_FADE_TIME)
	tween.tween_callback(ghost.queue_free)


# =========================================================
# RESET DRAWING
# =========================================================

func apply_speed_boost(boost: float) -> void:
	speed_multiplier += boost


func add_bomb(amount: int = 1) -> void:
	bombs += amount


func _throw_bomb() -> void:
	var bomb := BOMB_SCENE.instantiate()
	bomb.global_position = global_position

	get_parent().add_child(bomb)


func reset() -> void:

	line.clear_points()

	line.add_point(global_position)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.a = global_position
		line_collision.shape.b = global_position


# =========================================================
# HEALTH
# =========================================================

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	lives = max(lives - amount, 0)

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_hearts"):
		hud.set_hearts(lives)

	if lives <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	hide()

	var dead_screen = get_tree().get_first_node_in_group("dead_screen")
	if dead_screen and dead_screen.has_method("show_dead"):
		dead_screen.show_dead()


func respawn() -> void:
	lives = MAX_LIVES
	is_dead = false
	velocity = Vector2.ZERO
	global_position = spawn_position
	reset()
	show()

	Global.reset_run()

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_hearts"):
		hud.set_hearts(lives)


# =========================================================
# TOWER / ENEMY DETECTED
# =========================================================

func _on_area_2d_body_shape_entered(
	body_rid: RID,
	body: Node2D,
	body_shape_index: int,
	local_shape_index: int
) -> void:

	if is_dead:
		return

	if body.is_in_group("enemies"):
		take_damage(1)

		if is_instance_valid(body):
			body.queue_free()

		return

	if not body.is_in_group("tower"):
		return

	if body.disabled:
		return


	# =====================================================
	# TOUCH SOUND
	# =====================================================

	if body.has_method("play_touch_sound"):
		body.play_touch_sound()

	if line.get_point_count() < 2:

		if line.get_point_count() == 0:
			line.add_point(global_position)

		line.add_point(body.global_position)

	else:
		line.set_point_position(
			1,
			body.global_position
		)

	if line_collision.shape is SegmentShape2D:
		line_collision.shape.b = body.global_position

	if is_instance_valid(zapper):
		zapper.addPoint(
			body.global_position,
			body
		)

extends Node2D

const SPAWN_INTERVAL_MIN := 0.12
const SPAWN_INTERVAL_MAX := 0.4

const COMET_SPEED_MIN := 600.0
const COMET_SPEED_MAX := 1000.0

const ASTEROID_SPEED_MIN := 40.0
const ASTEROID_SPEED_MAX := 90.0

const STAR_COUNT := 90
const STAR_MIN_SIZE := 1.0
const STAR_MAX_SIZE := 2.5

@export var asteroid_textures: Array[Texture2D] = []

var spawn_timer := 0.0
var active := false


func _ready() -> void:
	set_process(false)


func start() -> void:
	active = true
	spawn_timer = 0.0
	_spawn_stars()
	set_process(true)


func stop() -> void:
	active = false
	set_process(false)

	for child in get_children():
		child.queue_free()


func _spawn_stars() -> void:
	var viewport_size := get_viewport_rect().size

	for i in STAR_COUNT:
		var star := ColorRect.new()
		var size := randf_range(STAR_MIN_SIZE, STAR_MAX_SIZE)

		star.size = Vector2(size, size)
		star.position = Vector2(
			randf_range(0.0, viewport_size.x),
			randf_range(0.0, viewport_size.y)
		)
		star.color = Color(1.0, 1.0, 1.0, randf_range(0.35, 1.0))

		add_child(star)


func _process(delta: float) -> void:
	spawn_timer -= delta

	if spawn_timer <= 0.0:
		_spawn_streak()
		spawn_timer = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)


func _spawn_streak() -> void:
	var viewport_size := get_viewport_rect().size
	var center := viewport_size * 0.5

	# Start somewhere on a ring well outside the screen.
	var angle := randf_range(0.0, TAU)
	var radius := viewport_size.length() * 0.65
	var start_pos := center + Vector2(cos(angle), sin(angle)) * radius

	# Aim through the screen with some spread so paths differ.
	var target := center + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * viewport_size * 0.35
	var direction := (target - start_pos).normalized()

	if asteroid_textures.size() > 0 and randf() < 0.5:
		_spawn_asteroid(start_pos, direction)
	else:
		_spawn_comet(start_pos, direction)


func _spawn_asteroid(start_pos: Vector2, direction: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = asteroid_textures[randi() % asteroid_textures.size()]
	sprite.position = start_pos
	sprite.rotation = randf_range(0.0, TAU)
	sprite.scale = Vector2.ONE * randf_range(1.5, 3.0)

	add_child(sprite)
	_animate_streak(sprite, direction, randf_range(ASTEROID_SPEED_MIN, ASTEROID_SPEED_MAX))


func _spawn_comet(start_pos: Vector2, direction: Vector2) -> void:
	var comet := Node2D.new()
	comet.position = start_pos
	add_child(comet)

	var tail := Line2D.new()
	tail.width = 3.0
	tail.default_color = Color(0.75, 0.9, 1.0, 0.0)
	tail.gradient = _make_tail_gradient()
	tail.points = PackedVector2Array([Vector2.ZERO, -direction * 90.0])
	comet.add_child(tail)

	var head := ColorRect.new()
	head.color = Color(1.0, 1.0, 1.0, 0.95)
	head.size = Vector2(5, 5)
	head.position = -head.size / 2.0
	comet.add_child(head)

	_animate_streak(comet, direction, randf_range(COMET_SPEED_MIN, COMET_SPEED_MAX))


func _make_tail_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.75, 0.9, 1.0, 0.0))
	gradient.set_color(1, Color(0.75, 0.9, 1.0, 0.7))
	return gradient


func _animate_streak(node: Node2D, direction: Vector2, speed: float) -> void:
	var travel_distance := get_viewport_rect().size.length() * 1.4
	var duration := travel_distance / speed

	var tween := node.create_tween()
	tween.tween_property(node, "position", node.position + direction * travel_distance, duration)
	tween.tween_callback(node.queue_free)

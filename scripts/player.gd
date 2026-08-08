extends CharacterBody2D

const SPEED := 300.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED
const CLOSE_DISTANCE := 20.0

@onready var polygon: Polygon2D = $"../Polygon2D"

var points: Array[Vector2] = []
var drawing := false


func _ready() -> void:
	polygon.polygon = PackedVector2Array()


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

	# If we're currently drawing, check if we've returned
	# to the first point.
	if drawing and points.size() >= 3:
		var first_point_global := polygon.to_global(points[0])

		if global_position.distance_to(first_point_global) <= CLOSE_DISTANCE:
			close_polygon()

	queue_redraw()


func _on_area_2d_area_shape_entered(
	_area_rid: RID,
	_area: Area2D,
	_area_shape_index: int,
	_local_shape_index: int
) -> void:

	print("Collision!")

	var point := polygon.to_local(global_position)

	if points.is_empty():
		points.append(point)
		drawing = true

	elif point.distance_to(points[-1]) > CLOSE_DISTANCE:
		points.append(point)

	polygon.polygon = PackedVector2Array(points)

	print("Added point: ", point)

	queue_redraw()


func close_polygon() -> void:
	if points.size() < 3:
		return

	drawing = false

	polygon.polygon = PackedVector2Array(points)

	print("POLYGON CLOSED!")

	queue_redraw()


func _draw() -> void:
	for point in points:
		var global_point := polygon.to_global(point)
		var local_point := to_local(global_point)

		draw_circle(
			local_point,
			POINT_RADIUS,
			POINT_COLOR
		)

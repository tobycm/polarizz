extends CharacterBody2D

const SPEED := 300.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED
const CLOSE_DISTANCE := 25.0
const MIN_POINT_DISTANCE := 10.0

@onready var polygon: Polygon2D = $"../Polygon2D"

var points: Array[Vector2] = []
var drawing := false
var polygon_finished := false

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


	queue_redraw()

func _on_area_2d_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	print("Collision with: ", _body.name, " at ", _body.global_position)
	if polygon_finished:
		return
	if _body == null:
		return
	# Use the player's position.
	var point := polygon.to_local(_body.global_position)

	# First collision = point 1.
	if points.is_empty():
		points.append(point)
		drawing = true

		print("Point 1: ", point)

	# Add another point if it's far enough from the previous point.
	elif point.distance_to(points[-1]) >= MIN_POINT_DISTANCE:
		points.append(point)

		print("Added point ", points.size(), ": ", point)
	if drawing and not polygon_finished and points.size() >= 3:
		var first_point_global := polygon.to_global(points[0])
		if _body.global_position.distance_to(first_point_global) <= CLOSE_DISTANCE:
			finish_polygon()
	queue_redraw()

func finish_polygon() -> void:
	if polygon_finished:
		return

	if points.size() < 3:
		return

	polygon_finished = true
	drawing = false

	# ONLY NOW does the polygon become filled.
	polygon.polygon = PackedVector2Array(points)

	print("POLYGON CREATED!")
	print("Total points: ", points.size())

	queue_redraw()

func _draw() -> void:
# Draw the points while the player is making the shape.
	for point in points:
		var global_point := polygon.to_global(point)
		var local_point := to_local(global_point)

		draw_circle(
			local_point,
			POINT_RADIUS,
			POINT_COLOR
		)

		if points.size() >= 2 and not polygon_finished:
			for i in range(points.size() - 1):
				var global_a := polygon.to_global(points[i])
				var global_b := polygon.to_global(points[i + 1])

				var local_a := to_local(global_a)
				var local_b := to_local(global_b)

				draw_line(
					local_a,
					local_b,
					POINT_COLOR,
					3.0
				)

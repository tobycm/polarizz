extends StaticBody2D

const CLOSE_DISTANCE := 25.0
const MIN_POINT_DISTANCE := 10.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED

@onready var polygon: Polygon2D = $"Polygon2D"
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var points: Array[Vector2] = []
var drawing := false
var polygon_finished := false

func _ready() -> void:
	polygon.polygon = PackedVector2Array()

func addPoint(tower_position: Vector2) -> void:

	if polygon_finished:
		return
	var point := polygon.to_local(tower_position)
	if points.is_empty():
		points.append(point)
		drawing = true
		print("Point 1: ", point)
		queue_redraw()
		return
	if point.distance_to(points[-1]) < MIN_POINT_DISTANCE:
		return
	points.append(point)

	print("Added point ", points.size(), ": ", point)
	check_for_completion(tower_position)
	queue_redraw()

func check_for_completion(player_position: Vector2) -> void:

	if not drawing:
		return

	if polygon_finished:
		return

	if points.size() < 3:
		return

	var first_point_global := polygon.to_global(points[0])


	# Check if the player is back at point 1.
	if player_position.distance_to(first_point_global) <= CLOSE_DISTANCE:

		print("PLAYER RETURNED TO POINT 1!")

		finish_polygon()

# =========================================================

# CREATE THE FINAL POLYGON

# =========================================================

func finish_polygon() -> void:

	if polygon_finished:
		return

	if points.size() < 3:
		return

	polygon_finished = true
	drawing = false

	# The polygon is ONLY created/fillled here.
	polygon.polygon = PackedVector2Array(points)

	print("================================")
	print("POLYGON CREATED!")
	print("TOTAL POINTS: ", points.size())
	print("================================")

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

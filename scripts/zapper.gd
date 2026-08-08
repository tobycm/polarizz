extends StaticBody2D

const CLOSE_DISTANCE := 25.0
const MIN_POINT_DISTANCE := 10.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED

@onready var polygon: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var points: Array[Vector2] = []
var drawing := false
var polygon_finished := false

func _ready() -> void:
	polygon.polygon = PackedVector2Array()
	collision_polygon_2d.polygon = PackedVector2Array()

func addPoint(tower_position: Vector2) -> void:

	if polygon_finished:
		return

	# Convert global position to the StaticBody2D's local space.
	var point := to_local(tower_position)


	# First point
	if points.is_empty():

		points.append(point)
		drawing = true

		print("Point 1: ", point)

		queue_redraw()
		return


	# Don't add points that are too close together.
	if point.distance_to(points[-1]) < MIN_POINT_DISTANCE:
		return


	# Add point.
	points.append(point)

	print("Added point ", points.size(), ": ", point)

	# Check if the player has returned to point 1.
	check_for_completion(tower_position)

	queue_redraw()

# =========================================================

# CHECK FOR RETURN TO POINT 1

# =========================================================

func check_for_completion(player_position: Vector2) -> void:

	if not drawing:
		return

	if polygon_finished:
		return

	if points.size() < 3:
		return


	# Point 1 is stored in StaticBody2D local coordinates.
	# Convert it back to global coordinates.
	var first_point_global := to_global(points[0])


	# Player must physically return to point 1.
	if player_position.distance_to(first_point_global) <= CLOSE_DISTANCE:

		print("PLAYER RETURNED TO POINT 1!")

		finish_polygon()

	# =========================================================

	# CREATE FINAL POLYGON

	# =========================================================

func finish_polygon() -> void:

	if polygon_finished:
		return

	if points.size() < 3:
		return

	polygon_finished = true
	drawing = false


	var final_polygon := PackedVector2Array(points)


	# -------------------------------------------------------
	# VISIBLE POLYGON
	# -------------------------------------------------------

	polygon.polygon = final_polygon


	# -------------------------------------------------------
	# COLLISION POLYGON
	# -------------------------------------------------------

	collision_polygon_2d.polygon = final_polygon


	print("================================")
	print("POLYGON CREATED!")
	print("TOTAL POINTS: ", points.size())
	print("================================")

	queue_redraw()

	# =========================================================

	# DRAW POINTS + PATH

	# =========================================================

func _draw() -> void:

	# Draw every point.
	for point in points:

		draw_circle(
			point,
			POINT_RADIUS,
			POINT_COLOR
		)


	if points.size() >= 2 and not polygon_finished:

		for i in range(points.size() - 1):

			draw_line(
				points[i],
				points[i + 1],
				POINT_COLOR,
				3.0
			)

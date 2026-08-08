extends StaticBody2D

const CLOSE_DISTANCE := 25.0
const MIN_POINT_DISTANCE := 10.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED

const ACTIVE_TIME := 1.0
@onready var line: Line2D = $Line2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var points: Array[Vector2] = []
var drawing := false
var polygon_finished := false

var zapper_active := false
var active_timer := 0.0


func _ready() -> void:
	polygon.polygon = PackedVector2Array()
	collision_polygon_2d.polygon = PackedVector2Array()


func _process(delta: float) -> void:
	if zapper_active:
		active_timer += delta

		if active_timer >= ACTIVE_TIME:
			reset_zapper()

func addPoint(tower_position: Vector2) -> void:
	if polygon_finished:
		return

	var point := to_local(tower_position)

	# First tower
	if points.is_empty():
		points.append(point)
		drawing = true

		print("Point 1: ", point)

		queue_redraw()
		return


	# -------------------------------------------------
	# ARE WE RETURNING TO THE START?
	# -------------------------------------------------

	var first_point_global := to_global(points[0])

	if tower_position.distance_to(first_point_global) <= CLOSE_DISTANCE:

		# Need at least THREE different towers first.
		if points.size() >= 3:
			print("RETURNED TO START - CLOSING POLYGON")
			finish_polygon()
		else:
			print("NOT ENOUGH TOWERS TO CLOSE POLYGON")

		return


	# -------------------------------------------------
	# NORMAL NEW TOWER
	# -------------------------------------------------

	# Don't add basically the same point twice.
	if point.distance_to(points[-1]) < MIN_POINT_DISTANCE:
		return

	points.append(point)

	print("Added point ", points.size(), ": ", point)

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

	var first_point_global := to_global(points[0])

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

	# Close Line2D visually (last -> first)
	line.add_point(points[0])

	var final_polygon := PackedVector2Array(points)

	polygon.polygon = final_polygon
	collision_polygon_2d.polygon = final_polygon

	# Start 1-second active period
	zapper_active = true
	active_timer = 0.0

	print("================================")
	print("POLYGON CREATED!")
	print("TOTAL POINTS: ", points.size())
	print("ZAPPER ACTIVE FOR 1 SECOND")
	print("================================")

	queue_redraw()


# =========================================================
# RESET AFTER 1 SECOND
# =========================================================

func reset_zapper() -> void:
	zapper_active = false
	active_timer = 0.0

	# Remove old active zone
	polygon.polygon = PackedVector2Array()
	collision_polygon_2d.polygon = PackedVector2Array()

	# Clear path so player must walk towers again
	points.clear()
	line.clear_points() # clear Line2D
	drawing = false
	polygon_finished = false

	print("ZAPPER RESET")

	queue_redraw()

func _draw() -> void:
	for point in points:
		draw_circle(point, POINT_RADIUS, POINT_COLOR)

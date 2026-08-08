extends StaticBody2D

const CLOSE_DISTANCE := 25.0
const MIN_POINT_DISTANCE := 10.0
const POINT_RADIUS := 6.0
const POINT_COLOR := Color.RED
const LINE_COLOR := Color.WHITE

const ACTIVE_TIME := 1.0
@onready var line: Line2D = $Line2D
@onready var polygon: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
var zapped_towers=[]
var points: Array[Vector2] = []
var drawing := false
var polygon_finished := false

var zapper_active := false
var active_timer := 0.0


func _ready() -> void:
	add_to_group("zapper")

	polygon.polygon = PackedVector2Array()
	collision_polygon_2d.polygon = PackedVector2Array()
	line.points = PackedVector2Array()
	line.position = Vector2.ZERO


func _process(delta: float) -> void:
	if zapper_active:
		active_timer += delta
		if active_timer >= ACTIVE_TIME:
			reset_zapper()


func addPoint(tower_position: Vector2, tower:Node2D) -> void:
	if polygon_finished:
		return

	# convert incoming global position to this node's local coords (parent-local)
	var point: Vector2 = to_local(tower_position)

	if points.is_empty():
		zapped_towers.append(tower)
		points.append(point)
		drawing = true
		update_line_from_points()
		print("Point 1: ", point)
		return

	var first_point_global := to_global(points[0])

	if tower_position.distance_to(first_point_global) <= CLOSE_DISTANCE:
		if points.size() >= 3:
			print("RETURNED TO START - CLOSING POLYGON")
			call_deferred("finish_polygon")
		else:
			print("NOT ENOUGH TOWERS TO CLOSE POLYGON")
		return


	if point.distance_to(points[-1]) < MIN_POINT_DISTANCE:
		return

	points.append(point)
	zapped_towers.append(tower)
	update_line_from_points()

	print("Added point ", points.size(), ": ", point)

	#line.update()


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
		call_deferred("finish_polygon")


func finish_polygon() -> void:
	if polygon_finished:
		return

	if points.size() < 3:
		return
	# Reset player line
	var player := get_tree().get_first_node_in_group("player")

	if player:
		player.reset()
	print("================================")
	print("POLYGON CREATED!")
	print("TOTAL POINTS: ", points.size())
	print("================================")

	polygon_finished = true
	drawing = false
	zapper_active = true
	active_timer = 0.0

	# Close visual line
	update_line_from_points(true)

	# Create polygon
	var final_polygon := PackedVector2Array(points)

	polygon.polygon = final_polygon
	collision_polygon_2d.call_deferred("set", "polygon", final_polygon)

	# Disable towers
	for tower in zapped_towers:
		if is_instance_valid(tower):
			tower.disable()

	print("ZAPPER ACTIVE")


# =========================================================
# RESET AFTER 1 SECOND
# =========================================================

func reset_zapper() -> void:
	print("========== RESET ZAPPER ==========")

	active_timer = 0.0
	zapper_active = false
	polygon_finished = false
	drawing = false

	# Clear polygon
	polygon.polygon = PackedVector2Array()
	collision_polygon_2d.polygon = PackedVector2Array()

	# Clear drawing
	line.points = PackedVector2Array()

	# Clear stored points
	points.clear()
	zapped_towers.clear()

	

	print("ZAPPER READY FOR NEXT ROUND")


func update_line_from_points(close: bool = false) -> void:
	var pts: Array[Vector2] = []
	for p in points:
		pts.append(p)
	if close and points.size() >= 1:
		pts.append(points[0])
	line.points = PackedVector2Array(pts)


func _draw() -> void:
	for point in points:
		draw_circle(point, POINT_RADIUS, POINT_COLOR)

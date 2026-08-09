extends Node

# =====================================================
# LEVEL SETTINGS
# =====================================================

const MIN_LEVEL := 1
const MAX_LEVEL := 5

var current_level := 1


# =====================================================
# LEVEL SCENES
# =====================================================

var levels := {
	1: preload("res://scenes/levels/level_1.tscn"),
	2: preload("res://scenes/levels/level_2.tscn"),
	3: preload("res://scenes/levels/level_3.tscn"),
	4: preload("res://scenes/levels/level_4.tscn"),
	5: preload("res://scenes/levels/level_5.tscn")
}


# =====================================================
# LEVEL CONTAINER
# =====================================================
@onready var level_container: Node2D = $level_container




# =====================================================
# READY
# =====================================================

func _ready() -> void:
	add_to_group("scene_manager")
	load_level(current_level)


func load_level(level: int) -> void:
	if not levels.has(level):
		push_error("Level %d does not exist!" % level)
		return

	# Remove current level
	for child in level_container.get_children():
		child.queue_free()

	# Create new level
	var new_level = levels[level].instantiate()

	level_container.add_child(new_level)

	current_level = level
	Global.register_level(level)


func increase_level() -> void:
	if current_level >= MAX_LEVEL:
		finish_game()
		return

	current_level += 1
	load_level(current_level)


# =====================================================
# GO TO SPECIFIC LEVEL
# =====================================================

func go_to_level(level: int) -> void:
	if level < MIN_LEVEL or level > MAX_LEVEL:
		push_error("Invalid level: %d" % level)
		return

	load_level(level)


func restart_level() -> void:
	load_level(current_level)


# =====================================================
# FINISH GAME
# =====================================================

func finish_game() -> void:
	print("ALL LEVELS COMPLETE!")

	# Put your win-game logic here.

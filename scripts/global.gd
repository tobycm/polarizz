extends Node

const SAVE_PATH := "user://polarizz_save.json"
const SCORE_PER_KILL := 100

var score := 0
var high_score := 0
var highest_level := 1


func _ready() -> void:
	_load()


func add_kill_score() -> void:
	score += SCORE_PER_KILL

	if score > high_score:
		high_score = score
		_save()

	_update_hud()


func register_level(level: int) -> void:
	if level > highest_level:
		highest_level = level
		_save()


func reset_run() -> void:
	score = 0
	_update_hud()


func _update_hud() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("set_score"):
		hud.set_score(score, high_score)


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var data = JSON.parse_string(file.get_as_text())

	if typeof(data) == TYPE_DICTIONARY:
		high_score = int(data.get("high_score", 0))
		highest_level = int(data.get("highest_level", 1))


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify({
		"high_score": high_score,
		"highest_level": highest_level,
	}))

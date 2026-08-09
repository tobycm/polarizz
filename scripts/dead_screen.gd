extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var comet_field: Node2D = $Overlay/CometField
@onready var stats_label: Label = $Overlay/Center/VBoxContainer/StatsLabel


func _ready() -> void:
	add_to_group("dead_screen")
	overlay.visible = false


func show_dead() -> void:
	overlay.visible = true
	comet_field.start()

	stats_label.text = "SCORE %06d\nHIGH SCORE %06d\nBEST LEVEL %02d" % [
		Global.score,
		Global.high_score,
		Global.highest_level,
	]


func hide_dead() -> void:
	overlay.visible = false
	comet_field.stop()


func _on_respawn_pressed() -> void:
	hide_dead()

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("respawn"):
		player.respawn()

	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.go_to_level(1)

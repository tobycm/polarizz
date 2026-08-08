extends CanvasLayer

@onready var overlay: Control = $Overlay


func _ready() -> void:
	add_to_group("dead_screen")
	overlay.visible = false


func show_dead() -> void:
	overlay.visible = true


func hide_dead() -> void:
	overlay.visible = false


func _on_respawn_pressed() -> void:
	hide_dead()

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("respawn"):
		player.respawn()

	var scene_manager = get_tree().get_first_node_in_group("scene_manager")
	if scene_manager:
		scene_manager.go_to_level(1)

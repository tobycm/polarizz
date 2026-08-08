extends Node

const SCENES = {
	"main_menu": "res://scenes/menus/main_menu.tscn",
	"level_1": "res://scenes/levels/level_test.tscn",
	"game_over": "res://scenes/menus/game_over.tscn"
}

# The public function you will call from other scripts
func switch_to_scene(scene_alias: String) -> void:
	if not SCENES.has(scene_alias):
		push_error("SceneManager: Scene alias '%s' does not exist." % scene_alias)
		return
		
	var scene_path = SCENES[scene_alias]
	
	# We use call_deferred to safely change the scene at the end of the current frame
	# This prevents crashes if a physics callback or signal is currently running
	call_deferred("_deferred_switch_scene", scene_path)

func _deferred_switch_scene(scene_path: String) -> void:
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("SceneManager: Failed to load scene at path: " + scene_path)

extends CanvasLayer

const LAST_ABILITY_LEVEL := 3

@onready var overlay: Control = $Overlay
@onready var card_container: HBoxContainer = $Overlay/Cards/HBoxContainer


func _ready() -> void:
	add_to_group("ability_manager")

	for card in card_container.get_children():
		card.selected.connect(_on_card_selected)


func show_cards() -> void:
	var scene_manager = get_tree().get_first_node_in_group("scene_manager")

	# Only offer ability cards after the asteroid levels (1-3). Beyond that,
	# skip straight to the next level so the page never shows again.
	if scene_manager and scene_manager.current_level >= LAST_ABILITY_LEVEL:
		scene_manager.increase_level()
		return

	overlay.visible = true


func hide_cards() -> void:
	overlay.visible = false


func _on_card_selected(ability_id: String, value: float) -> void:
	hide_cards()

	var player = get_tree().get_first_node_in_group("player")

	match ability_id:
		"speed":
			if player and player.has_method("apply_speed_boost"):
				player.apply_speed_boost(value)
		"bomb":
			if player and player.has_method("add_bomb"):
				player.add_bomb(int(value))

	var upgrader_panel = get_tree().get_first_node_in_group("upgrader_panel")
	if upgrader_panel and upgrader_panel.has_method("add_ability_icon"):
		upgrader_panel.add_ability_icon(ability_id)

	get_tree().get_first_node_in_group("scene_manager").increase_level()

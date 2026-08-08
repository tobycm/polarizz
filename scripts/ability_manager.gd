extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var card_container: HBoxContainer = $Overlay/Cards/HBoxContainer


func _ready() -> void:
	add_to_group("ability_manager")

	for card in card_container.get_children():
		card.selected.connect(_on_card_selected)


func show_cards() -> void:
	overlay.visible = true


func hide_cards() -> void:
	overlay.visible = false


func _on_card_selected(speed_boost: float) -> void:
	hide_cards()

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_speed_boost"):
		player.apply_speed_boost(speed_boost)

	get_tree().get_first_node_in_group("scene_manager").increase_level()

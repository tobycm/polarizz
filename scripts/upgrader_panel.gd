extends Node2D

# Centers of the 4 "UPG" module slots in the UpgraderPanel/UiOverlay sprite,
# measured directly from assets/ui_overlay .png and converted into this
# CanvasLayer's coordinate space (UiOverlay position + (pixel - texture_center) * scale).
const SLOT_POSITIONS := [
	Vector2(1010.2, 283.5),
	Vector2(1106.9, 283.5),
	Vector2(1010.2, 371.6),
	Vector2(1106.9, 371.6),
]

const SLOT_TARGET_HEIGHT := 44.0

const ABILITY_ICONS := {
	"speed": preload("res://assets/abilities/speed_1.png"),
	"bomb": preload("res://assets/tnt_1.png"),
}

var slots: Array[Sprite2D] = []
var icons: Array[Texture2D] = []


func _ready() -> void:
	add_to_group("upgrader_panel")

	for slot_position in SLOT_POSITIONS:
		var slot := Sprite2D.new()
		slot.position = slot_position
		slot.visible = false
		add_child(slot)
		slots.append(slot)


func add_ability_icon(ability_id: String) -> void:
	var texture: Texture2D = ABILITY_ICONS.get(ability_id)

	if texture == null or icons.size() >= slots.size():
		return

	var index := icons.size()
	icons.append(texture)

	var slot := slots[index]
	slot.texture = texture
	slot.centered = true
	slot.scale = Vector2.ONE * (SLOT_TARGET_HEIGHT / texture.get_height())
	slot.visible = true


func clear_icons() -> void:
	icons.clear()

	for slot in slots:
		slot.visible = false
		slot.texture = null

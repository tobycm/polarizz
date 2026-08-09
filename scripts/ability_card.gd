extends Button

signal selected(ability_id: String, value: float)

@export var texture: Texture2D
@export var ability_id: String = "speed"
@export var value: float = 0.0

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func _ready() -> void:
	texture_rect.texture = texture
	label.text = _label_text()
	pressed.connect(func() -> void: selected.emit(ability_id, value))


func _label_text() -> String:
	match ability_id:
		"speed":
			return "+%d%% Speed" % int(round(value * 100.0))
		"bomb":
			return "Bomb"
		_:
			return ability_id

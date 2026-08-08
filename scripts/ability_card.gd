extends Button

signal selected(speed_boost: float)

@export var texture: Texture2D
@export var speed_boost: float = 0.0

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func _ready() -> void:
	texture_rect.texture = texture
	label.text = "+%d%% Speed" % int(round(speed_boost * 100.0))
	pressed.connect(func() -> void: selected.emit(speed_boost))

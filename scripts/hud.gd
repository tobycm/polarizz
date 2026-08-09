extends CanvasLayer

@export var full_texture: Texture2D
@export var empty_texture: Texture2D

@onready var hearts: Array[TextureRect] = [$Hearts/Heart1, $Hearts/Heart2, $Hearts/Heart3]
@onready var score_label: Label = $ScoreBoard/ScoreLabel
@onready var high_score_label: Label = $ScoreBoard/HighScoreLabel
@onready var bomb_label: Label = $AbilityBar/BombLabel
@onready var dash_label: Label = $AbilityBar/DashLabel


func _ready() -> void:
	add_to_group("hud")
	set_hearts(hearts.size())
	set_score(Global.score, Global.high_score)
	set_bombs(0)
	set_dash_ready(true)


func set_hearts(lives: int) -> void:
	for i in hearts.size():
		hearts[i].texture = full_texture if i < lives else empty_texture


func set_score(score: int, high_score: int) -> void:
	score_label.text = "SCORE %06d" % score
	high_score_label.text = "HI %06d" % high_score


func set_bombs(count: int) -> void:
	bomb_label.text = "BOMBS %d" % count
	bomb_label.modulate.a = 1.0 if count > 0 else 0.5


func set_dash_ready(ready: bool) -> void:
	dash_label.text = "DASH READY" if ready else "DASH..."
	dash_label.modulate.a = 1.0 if ready else 0.5

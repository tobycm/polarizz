extends CanvasLayer

@export var full_texture: Texture2D
@export var empty_texture: Texture2D

@onready var hearts: Array[TextureRect] = [$Hearts/Heart1, $Hearts/Heart2, $Hearts/Heart3,$Hearts2/Heart1, $Hearts2/Heart2, $Hearts2/Heart3]
@onready var score_label: Label = $ScoreBoard/ScoreLabel
@onready var high_score_label: Label = $ScoreBoard/HighScoreLabel


func _ready() -> void:
	add_to_group("hud")
	set_hearts(hearts.size())
	set_score(Global.score, Global.high_score)


func set_hearts(lives: int) -> void:
	for i in hearts.size():
		hearts[i].texture = full_texture if i < lives else empty_texture


func set_score(score: int, high_score: int) -> void:
	score_label.text = "SCORE %06d" % score
	high_score_label.text = "HI %06d" % high_score

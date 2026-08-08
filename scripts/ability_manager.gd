extends Node

var speed_level: int = 0

const SPEED_MULTIPLIERS := [
	1.0,
	1.15,
	1.30,
	1.50
]

func upgrade_speed() -> void:
	if speed_level < 3:
		speed_level += 1

func get_speed_multiplier() -> float:
	return SPEED_MULTIPLIERS[speed_level]

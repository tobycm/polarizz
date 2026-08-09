extends Node

# Global screen-shake helper (autoload).
# Works with whatever Camera2D is currently active in the viewport, so it
# requires zero setup in individual level scenes.
#
# Usage:
#   ScreenShake.shake(8.0)          # small shake
#   ScreenShake.shake(16.0, 0.4)    # bigger shake, longer duration

var _trauma := 0.0
var _decay := 2.5  # trauma lost per second
var _max_offset := 24.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	set_process(true)


func shake(amount: float = 10.0, duration: float = 0.25) -> void:
	# `duration` mostly maps to how much trauma decays; longer duration => slower decay this hit.
	_decay = clamp(1.0 / max(duration, 0.05), 1.0, 20.0)
	_trauma = clamp(_trauma + amount / _max_offset, 0.0, 1.0)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		return

	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	_trauma = max(_trauma - _decay * delta, 0.0)

	# Squared falloff feels punchier than linear.
	var strength := _trauma * _trauma
	var offset := Vector2(
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0)
	) * _max_offset * strength

	camera.offset = offset

	if _trauma <= 0.0:
		camera.offset = Vector2.ZERO

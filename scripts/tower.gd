extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var disable_timer: Timer = $Timer
@onready var touch_sound: AudioStreamPlayer2D = $TouchSound

const DISABLE_ANIMS := ["0", "1", "2", "3"]
var disable_step := 0
var disabled=false

func play_touch_sound() -> void:
	touch_sound.play()

func disable() -> void:
	collision_shape.disabled = true
	disabled=true
	disable_step = 0
	_play_disable_step()


func _on_timer_timeout() -> void:
	disable_step += 1

	if disable_step < DISABLE_ANIMS.size():
		_play_disable_step()
	else:
		disable_timer.stop()
		collision_shape.disabled = false
		disabled=false


func _play_disable_step() -> void:
	animated_sprite_2d.play(DISABLE_ANIMS[disable_step])

	if disable_step < DISABLE_ANIMS.size() - 1:
		disable_timer.start()

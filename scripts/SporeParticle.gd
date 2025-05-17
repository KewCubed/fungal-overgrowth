extends Node2D

var velocity = Vector2.ZERO
var lifetime = 0.8
var fade_timer := 0.0
var rotation_speed := 0.0

@onready var sprite = $Sprite2D

func _ready():
	# Random velocity
	var speed = randf_range(80, 150)
	var angle = randf_range(0, TAU)
	velocity = Vector2.RIGHT.rotated(angle) * speed

	# Random spin speed
	rotation_speed = randf_range(-3.0, 3.0)

	# Initial color
	sprite.modulate.a = 1.0

	set_process(true)

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta

	# Fade out
	fade_timer += delta
	var alpha = clamp(1.0 - (fade_timer / lifetime), 0.0, 1.0)
	sprite.modulate.a = alpha

	if fade_timer >= lifetime:
		queue_free()

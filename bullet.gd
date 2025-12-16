extends RigidBody2D

const SPEED: float = 300

@export var velocity: Vector2

func _ready() -> void:
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 5
	timer.timeout.connect(_dispose_bullet)

func _dispose_bullet():
	queue_free()

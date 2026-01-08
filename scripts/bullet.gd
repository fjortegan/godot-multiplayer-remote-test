extends RigidBody2D

const SPEED: float = 300
const DURATION: float = 1

@export var velocity: Vector2

const DAMAGE: float = 20.0

func _ready() -> void:
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = DURATION
	timer.timeout.connect(dispose_bullet)
	add_child(timer)

func dispose_bullet():
	queue_free()

extends RigidBody2D

const SPEED: float = 300
const DURATION: float = 1

@export var velocity: Vector2
@export var color: Color = Color.WHITE
@export var player_id: int

const DAMAGE: float = 10.0

func _enter_tree() -> void:
	set_multiplayer_authority(player_id)

func _ready() -> void:
	Global.current_lobby.debug_log("Color: %s - ID : %d" % [str(color), player_id])
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	var timer = Timer.new()
	$Sprite2D.modulate = color
	timer.autostart = true
	timer.wait_time = DURATION
	timer.timeout.connect(dispose_bullet)
	add_child(timer)

@rpc("any_peer", "call_local", "reliable")
func dispose_bullet():
	queue_free()

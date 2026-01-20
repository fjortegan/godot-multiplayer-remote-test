extends RigidBody2D

const SPEED: float = 300

@export var velocity: Vector2
@export var color: Color = Color.WHITE
@export var player_id: int

@onready var sprite = $Sprite2D

const DAMAGE: float = 10.0

func _enter_tree() -> void:
	Global.current_lobby.debug_log("enter bullet: %d %s %s" % [player_id, color, velocity])
	set_multiplayer_authority(player_id)

func _ready() -> void:
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	sprite.modulate = color
	#if not is_multiplayer_authority(): return

func _on_bullet_timeout():
	Global.current_lobby.debug_log("bullet timeout...")
	dispose_bullet()

@rpc("any_peer", "call_local", "reliable")
func dispose_bullet():
	Global.current_lobby.debug_log("dispose bullet...")
	$MultiplayerSynchronizer.public_visibility = false
	visible = false
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	call_deferred("queue_free")

class_name Player
extends CharacterBody2D

const SPEED: float = 200.0
const OFFSET: float = 0.1

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		$LPCAnimatedSprite2D.spritesheets_path = "res://images/characters/" + Lobby.player_info["avatar"].id
		$Nickname.text = Lobby.player_info["name"]

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return 
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	if velocity == Vector2.ZERO:
		$LPCAnimatedSprite2D.play_animation("idle", "south")
	else:
		$LPCAnimatedSprite2D.play_animation("walk", _direction_string(velocity))
	move_and_slide()

func _direction_string(value: Vector2) -> String:
	var direction = "south"
	if value.x > OFFSET:
		direction = "east"
	elif  value.x < -OFFSET:
		direction = "west"
	elif value.y < -OFFSET:
		direction = "north"
	return direction

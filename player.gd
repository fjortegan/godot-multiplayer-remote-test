class_name Player
extends CharacterBody2D

@export var spawn_position = Vector2.ZERO

const SPEED: float = 200.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	$LPCAnimatedSprite2D.spritesheets_path = "res://images/characters/p" + ("1" if name == "1" else "2")
	#Lobby.debug_log("enter tree: "+$LPCAnimatedSprite2D.spritesheets_path)

func _ready() -> void:
	#Lobby.debug_log("spawn position: " + str(spawn_position))
	position = spawn_position

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return 
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	
	move_and_slide()

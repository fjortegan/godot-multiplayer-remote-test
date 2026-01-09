class_name Player
extends CharacterBody2D

@export var index: int
@export var bullet: PackedScene

var player_layers: Array[int] = [1, 2, 4, 8]
var bullet_layers: Array[int] = [16, 32, 64, 128]
var collision_masks: Array[int] = [238, 221, 187, 119]

var time_left: float = 5
var alive_timer: Timer
@export var player_alive: bool = true
@export var current_life: float

const SPEED: float = 200.0
const OFFSET: float = 0.1
const MAXLIFE: float = 50.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	current_life = MAXLIFE
	#alive_timer = Timer.new()
	#alive_timer.wait_time = time_left
	#alive_timer.autostart = true
	#alive_timer.timeout.connect(_on_death)
	#add_child(alive_timer)
	
	if is_multiplayer_authority():
		collision_layer = player_layers[index]
		collision_mask = collision_masks[index]
		$LPCAnimatedSprite2D.spritesheets_path = "res://images/characters/" + Global.current_lobby.player_info["avatar"].id
		$Nickname.text = Global.current_lobby.player_info["name"]
		$Nickname.add_theme_font_size_override("font_size", 12)
		$Nickname.add_theme_color_override("font_color", Color.LAWN_GREEN)

@rpc("any_peer", "call_local", "reliable")
func set_index(_index):
	index = _index
	collision_layer = player_layers[index]
	collision_mask = collision_masks[index]

func receive_damage(damage: float):
	current_life -= damage
	if current_life <= 0:
		current_life = 0
		_on_death()

func _on_death():
	player_alive = false
	$LPCAnimatedSprite2D.play_animation("hurt", "south")
	#queue_free()

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return 
	if event.is_action_pressed("ui_accept"):
		#shoot.rpc(velocity, Global.current_lobby.player_info["avatar"].bullet_color)
		shoot(velocity, Global.current_lobby.player_info["avatar"].bullet_color, name.to_int())

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return 
	$Nickname.text = Global.current_lobby.player_info["name"] + " %.0f PV" % current_life
	if player_alive:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
		if velocity == Vector2.ZERO:
			$LPCAnimatedSprite2D.play_animation("idle", "south")
		else:
			$LPCAnimatedSprite2D.play_animation("walk", _direction_string(velocity))
	move_and_slide()
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("Bullet"):
			collider.dispose_bullet.rpc()
			receive_damage(collider.DAMAGE)


#@rpc("call_local", "any_peer", "reliable")
func shoot(_velocity, _color, _player_id):
	var instance: RigidBody2D = bullet.instantiate()
	instance.color = _color
	instance.player_id = _player_id
	#instance.global_position = global_position
	instance.velocity = _velocity
	instance.collision_layer = bullet_layers[index]
	instance.collision_mask = collision_masks[index]
	$Bullets.add_child(instance, true)
	#instance.position = position ## medida relativa, evitar position
	#get_parent().add_child(instance)

func _direction_string(value: Vector2) -> String:
	var direction = "south"
	if value.x > OFFSET:
		direction = "east"
	elif  value.x < -OFFSET:
		direction = "west"
	elif value.y < -OFFSET:
		direction = "north"
	return direction

func _on_animation_finished() -> void:
	if not player_alive:
		queue_free()

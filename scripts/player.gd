class_name Player
extends CharacterBody2D

@export var index: int
@export var bullet: PackedScene
@export var player_alive: bool = true
@export var current_life: float

@onready var animation: LPCAnimatedSprite2D = $LPCAnimatedSprite2D
@onready var nickname = $Nickname

const SPEED: float = 200.0
const OFFSET: float = 0.1

const MAXLIFE: float = 50.0

# nickname helper local custom theme?
# TODO: refactor nickname helper
const FONTSIZE = 12 
const FONTCOLOR = Color.LAWN_GREEN 

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	current_life = MAXLIFE
	
	# TODO: refactor nickname helper
	if is_multiplayer_authority():
		animation.spritesheets_path = Global.get_avatar_path()
		nickname.text = Global.get_player_name()
		nickname.add_theme_font_size_override("font_size", FONTSIZE)
		nickname.add_theme_color_override("font_color", FONTCOLOR)

# receive damage and death
func receive_damage(damage: float):
	current_life -= damage
	if current_life <= 0:
		current_life = 0
		_on_death()

# change animation on death signal
func _on_death():
	player_alive = false
	animation.play_animation("hurt", "south")

# when dead animation is finished, dispose this node
func _on_animation_finished() -> void:
	if not player_alive:
		queue_free()
		
# input: shoot
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return # AUTHORITY ONLY
	if event.is_action_pressed("ui_accept"):
		shoot(velocity, Global.get_avatar().bullet_color, name.to_int())

# process: manages movement, animation and name helper 
func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return # AUTHORITY ONLY
	# TODO: refactor
	nickname.text = Global.get_player_name() + " %.0f PV" % current_life
	if player_alive:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
		if velocity == Vector2.ZERO:
			animation.play_animation("idle", "south")
		else:
			animation.play_animation("walk", _direction_string(velocity))
	move_and_slide()
	# detect bullet collisions
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		Global.current_lobby.debug_log("collision: " + name + " -> " + collider.name)
		if collider.is_in_group("Bullet"):
			#receive_damage(collider.DAMAGE)
			collider.dispose_bullet.rpc_id(collider.player_id)

# order shoot on game (called locally)
# TODO: create signal connected to Game
func shoot(_velocity, _color, _player_id):
	# get Game root node
	var root_node = get_parent().get_parent()
	Global.current_lobby.debug_log("player shoot %d" % _player_id)
	root_node.shoot(index, global_position, _velocity, Global.get_avatar().bullet_color)

# calculates direction for animations
func _direction_string(value: Vector2) -> String:
	var direction = "south"
	if value.x > OFFSET:
		direction = "east"
	elif  value.x < -OFFSET:
		direction = "west"
	elif value.y < -OFFSET:
		direction = "north"
	return direction

extends Node2D

@export var spawners: Array[MultiplayerSpawner]

var pressed_buttons: int = 0

func _ready():
	# Preconfigure game.
	if not multiplayer.is_server():
		Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	else:
		start_game()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	#Lobby.debug_log("game started: " + str(multiplayer.get_unique_id()))
	var i = 0
	for id in Lobby.players:
		spawners[i%4].spawn_player(id)
		i+=1
	$Button1.activation.connect(_on_button_pressed)
	$Button2.activation.connect(_on_button_pressed)

func _on_button_pressed(status: bool):
	if status:
		pressed_buttons += 1
	else:
		pressed_buttons -= 1 
	Lobby.debug_log("pressed buttons "+str(pressed_buttons))

extends Node2D

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
	$MultiplayerSpawner.spawn_player(multiplayer.get_unique_id())

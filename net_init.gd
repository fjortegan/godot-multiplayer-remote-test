extends Node2D

func _on_server_pressed() -> void:
	Lobby.create_game()
	enable_buttons(true)

func _on_client_pressed() -> void:
	Lobby.join_game()
	Lobby.player_connected.connect(_on_joined_game)
	enable_buttons(true)

func enable_buttons(status=false):
	$VBoxContainer/HBoxContainer4/ServerButton.disabled = status
	$VBoxContainer/HBoxContainer4/ClientButton.disabled = status

func _on_joined_game(peer_id, player_info):
	Lobby.debug_log("joining game: "+str(player_info)+" ("+str(peer_id)+")")
	Lobby.load_game("res://game.tscn")

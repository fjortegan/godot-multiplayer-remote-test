extends Node2D

func _on_server_pressed() -> void:
	Lobby.create_game()
	enable_buttons(false)

func _on_client_pressed() -> void:
	var peer = Lobby.join_game()
	Lobby.player_connected.connect(_on_joined_game)
	enable_buttons(false)

func enable_buttons(status=true):
	$VBoxContainer/HBoxContainer4/ServerButton.disabled = status
	$VBoxContainer/HBoxContainer4/ClientButton.disabled = status

func _on_joined_game(peer_id, player_info):
	Lobby.load_game("res://game.tscn")

extends Node2D


func _on_button_pressed() -> void:
	Lobby.create_game()
	$Button.disabled = true
	$Button2.disabled = true


func _on_button_2_pressed() -> void:
	var peer = Lobby.join_game()
	Lobby.player_connected.connect(_on_joined_game)
	$Button.disabled = true
	$Button2.disabled = true

func _on_joined_game(peer_id, player_info):
	Lobby.load_game("res://game.tscn")

extends Node2D


func _on_button_pressed() -> void:
	Lobby.create_game()
	$Button.disabled = true
	$Button2.disabled = true


func _on_button_2_pressed() -> void:
	var peer = Lobby.join_game()
	print(str(peer))
	print("status " + str(peer.get_connection_status()))
	Lobby.load_game("res://game.tscn")
	$Button.disabled = true
	$Button2.disabled = true

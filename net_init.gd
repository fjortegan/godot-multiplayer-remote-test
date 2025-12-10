extends Node2D

@onready var playername = $MainContainer/PlayerNameContainer/PlayerNameInput
@onready var serverbutton = $MainContainer/ButtonsContainer/ServerButton
@onready var clientbutton = $MainContainer/ButtonsContainer/ClientButton
@onready var statuslabel = $MainContainer/StatusLabel

func _on_server_pressed() -> void:
	if not _required_data():
		return
	Lobby.create_game()
	disable_buttons(true)

func _on_client_pressed() -> void:
	Lobby.join_game()
	Lobby.player_connected.connect(_on_joined_game)
	disable_buttons(true)

func disable_buttons(status=false):
	serverbutton.disabled = status
	clientbutton.disabled = status

func _on_joined_game(peer_id, player_info):
	#Lobby.debug_log("joining game: "+str(player_info)+" ("+str(peer_id)+")")
	Lobby.load_game("res://game.tscn")

func _required_data() -> bool:
	statuslabel.text = "Status: "
	var result = true
	if not playername.text: 
		statuslabel.text += "Name required "
		result = false
	if not SelectionManager.selected_avatar:
		statuslabel.text += "Avatar required "
		result = false
	return result

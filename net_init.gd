extends Node2D

@onready var playername = $MainContainer/PlayerNameContainer/PlayerNameInput
@onready var serverbutton = $MainContainer/ButtonsContainer/ServerButton
@onready var clientbutton = $MainContainer/ButtonsContainer/ClientButton
@onready var statuslabel = $MainContainer/StatusLabel
@onready var startgamebutton = $MainContainer/StartGameButton

func _on_server_pressed() -> void:
	if not _required_data():
		return
	Lobby.create_game()
	disable_buttons(true)
	startgamebutton.visible = true

func _on_start_pressed():
	Lobby.start_game()

func _on_client_pressed() -> void:
	if not _required_data():
		return
	Lobby.join_game()
	#Lobby.player_connected.connect(_on_joined_game)
	disable_buttons(true)

func disable_buttons(status=false):
	serverbutton.disabled = status
	clientbutton.disabled = status

#func _on_joined_game(peer_id, player_info):
	#Lobby.debug_log("joining game: "+str(player_info)+" ("+str(peer_id)+")")
	##Lobby.game_start.connect(_on_game_started)

func _on_game_started():
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
	if result:
		statuslabel.text += "Waiting "
		Lobby.player_info["name"] = playername.text
		Lobby.player_info["avatar"] = SelectionManager.avatar
	return result

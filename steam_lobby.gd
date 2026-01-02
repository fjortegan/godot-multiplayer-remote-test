extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal game_start

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Player 1", "avatar": "p1"}

var players_loaded = 0
var game_started: bool = false

var is_host: bool = false
var lobby_id: int

var steam_peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()

func _ready():
	var steam_status = Steam.steamInit(480, true)
	if steam_status:
		Steam.lobby_created.connect(_on_lobby_created)
		Steam.lobby_joined.connect(_on_lobby_joined)
		Steam.initRelayNetworkAccess()
	#Steam.lobby_game_created.connect(_on_lobby_game_created)
	print("Steam Status: %s" % steam_status)
	multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_ok)
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(_lobby_id = "0"):
	debug_log("Joining Lobby %s" % _lobby_id)
	Steam.joinLobby(_lobby_id.to_int())
	#if address.is_empty():
		#address = DEFAULT_SERVER_IP
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_client(address, PORT)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer
	#Lobby.debug_log("game joined " + str(peer.get_unique_id()))

func _on_lobby_joined(_lobby_id: int, _permissions: int, _locked: bool, _response: int):
	lobby_id = _lobby_id
	steam_peer.server_relay = true
	steam_peer.create_client(Steam.getLobbyOwner(lobby_id))
	debug_log("Looby joined: %d" % _lobby_id)
	multiplayer.multiplayer_peer = steam_peer
	
func create_game():
	debug_log("Creating Lobby")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 2)
	is_host = true
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(PORT, MAX_CONNECTIONS)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer
#
	#players[1] = player_info
	#player_connected.emit(1, player_info)
	##Lobby.debug_log("game created")
	#game_start.connect(_on_game_started)

func _on_lobby_created(_result:int, _lobby_id:int):
	if _result == Steam.Result.RESULT_OK:
		debug_log("Lobby created: %d" % _lobby_id)
		lobby_id = _lobby_id
		steam_peer.server_relay = true
		steam_peer.create_host()
		
		multiplayer.multiplayer_peer = steam_peer
		players[1] = player_info
		player_connected.emit(1, player_info)
		#Lobby.debug_log("game created")
		game_start.connect(_on_game_started)
	else:
		debug_log("Connection error: %d" % _result)

func _on_game_started():
	game_started = true
	load_game.rpc("res://game.tscn")	

func start_game():
	game_start.emit()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	#Lobby.debug_log("loading player")
	if multiplayer.is_server():
		players_loaded += 1
		#Lobby.debug_log("player loaded "+str(players_loaded))
		#Lobby.load_game("res://game.tscn")

		#if players_loaded == players.size():
			#$/root/Game.start_game()
			#players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	#Lobby.debug_log("register player " + str(new_player_id))


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
	
func debug_log(text: String):
	print(str(Time.get_ticks_msec())+"ms ("+str(multiplayer.get_unique_id()) + "): " + text)

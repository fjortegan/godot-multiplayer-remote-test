extends MultiplayerSpawner

@export var network_player: PackedScene
@export var server_player: PackedScene

var player: Player

func _ready() -> void:
	#multiplayer.peer_connected.connect(spawn_player)
	pass

func spawn_player(id: int, posx):
	if not multiplayer.is_server(): 
		return
	Lobby.debug_log("player spawn: "+str(id))
	player = network_player.instantiate()
	player.spawn_position = Vector2(posx, 0)

	player.name = str(id)
	get_node(spawn_path).call_deferred("add_child", player)
	player.fix_position.rpc(Vector2(posx, 0))

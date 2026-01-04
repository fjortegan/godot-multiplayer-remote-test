extends Node2D

@export var spawners: Array[MultiplayerSpawner]
@onready var players_nodes = $Players
var pressed_buttons: int = 0

func _ready():
	Global.current_lobby.server_disconnected.connect(_on_server_disconnected)
	Global.current_lobby.player_disconnected.connect(_on_player_disconnected)
	call_deferred("start_game_server")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

# Called only on the server.
func start_game_server():
	if multiplayer.is_server():
		var i = 0
		for id in Global.current_lobby.players:
			spawners[i%4].spawn_player(id, i)
			i+=1
		var button_nodes = $Buttons.get_children()
		for button in button_nodes:
			button.activation.connect(_on_button_pressed)
	else:
		Global.current_lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

func _on_button_pressed(status: bool):
	if status:
		pressed_buttons += 1
	else:
		pressed_buttons -= 1 
	
	if pressed_buttons >= 4:
		var door_scene: PackedScene = load("res://scenes/door.tscn")
		var instance = door_scene.instantiate()
		instance.name = "door"
		get_node("Doors").call_deferred("add_child", instance)
		#$Node2D/Door.show_door.rpc()

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_player_disconnected(id: int):
	if multiplayer.is_server():
		var player_node = players_nodes.find_child(str(id), true, false)
		if player_node:
			player_node.queue_free()

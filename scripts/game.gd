extends Node2D

@export var spawners: Array[MultiplayerSpawner]

var pressed_buttons: int = 0

func _ready():
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
		$Button1.activation.connect(_on_button_pressed)
		$Button2.activation.connect(_on_button_pressed)
		$Button3.activation.connect(_on_button_pressed)
		$Button4.activation.connect(_on_button_pressed)
	else:
		Global.current_lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


func _on_button_pressed(status: bool):
	if status:
		pressed_buttons += 1
	else:
		pressed_buttons -= 1 
	#Global.current_lobby.debug_log("pressed buttons "+str(pressed_buttons))
	
	if pressed_buttons >= 4:
		Global.current_lobby.debug_log("visible...")
		var door_scene: PackedScene = load("res://scenes/door.tscn")
		var instance = door_scene.instantiate()
		instance.name = "door"
		get_node("Node2D").call_deferred("add_child", instance)
		#$Node2D/Door.show_door.rpc()

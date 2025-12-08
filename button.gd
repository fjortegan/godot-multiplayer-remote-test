extends Sprite2D


func _on_area_2d_body_entered(_body: Node2D) -> void:
	Lobby.debug_log(name)


func _on_area_2d_body_exited(_body: Node2D) -> void:
	Lobby.debug_log("no " + name)

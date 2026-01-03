extends HBoxContainer

@export var id: int
@export var player_info: Dictionary

@onready var id_label = $Label
@onready var avatar_img = $TextureRect 
@onready var name_label = $Label2

func _ready() -> void:
	id_label.text = str(id)
	name_label.text = player_info["name"]
	var avatar_image
	var avatar =  load("res://resources/"+player_info["avatar_id"]+".tres") as Avatar
	#var avatar = player_info["avatar"]
	#if avatar is EncodedObjectAsID:
		#avatar =  load("res://resources/"+player_info["avatar_id"]+".tres") as Avatar		
		##avatar = instance_from_id(player_info["avatar"].get_object_id())
	avatar_image = avatar.image
		
	avatar_img.texture = avatar_image

extends HBoxContainer

@export var id: int
@export var player_info: Dictionary
@export var std_avatar: Avatar

@onready var id_label = $Label
@onready var avatar_img = $TextureRect 
@onready var name_label = $Label2

func _ready() -> void:
	id_label.text = str(id)
	name_label.text = player_info["name"]
	var avatar_image
	var avatar = player_info["avatar"]
	if avatar is EncodedObjectAsID:
		avatar = instance_from_id(player_info["avatar"].get_object_id())
	if not avatar:
		avatar = std_avatar
	avatar_image = avatar.image
		
	avatar_img.texture = avatar_image

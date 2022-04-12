class_name TeaData
extends Resource

export(String) var name : String
export(Texture) var bag_image : Texture
export(Color) var color : Color

func _to_string():
	return "%s (%d)" % [name, get_instance_id()]

func copy_from(value : TeaData):
	if value == null:
		return
	name = value.name
	bag_image = value.bag_image
	color = value.color

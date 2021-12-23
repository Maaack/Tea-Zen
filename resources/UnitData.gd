class_name UnitData
extends Resource

export(String) var name
export(Texture) var icon

func _to_string():
	return "%s (%d)" % [name, get_instance_id()]

func copy_from(value : UnitData):
	if value == null:
		return
	name = value.name
	icon = value.icon

extends Node

var _quantity_data_list : Array = [
	preload("res://resources/quantities/BlackTeaLeaves.tres"),
	preload("res://resources/quantities/ColdWater.tres"),
	preload("res://resources/quantities/HotWater.tres"),
	preload("res://resources/quantities/RawLeaves.tres"),
]

var container : ContainerData = ContainerData.new()

func get_container_data(key : String) -> QuantityData:
	var quantity_data : QuantityData = container.find_content(key)
	if quantity_data == null:
		container.add_content(_get_new_quantity(key))
		quantity_data = container.find_content(key)
	return quantity_data

func get_container_quantity(key : String) -> float:
	var quantity_data : QuantityData = container.find_content(key)
	if quantity_data != null:
		return quantity_data.quantity
	return 0.0

func _get_new_quantity(key : String) -> QuantityData:
	for quantity_data in _quantity_data_list:
		if quantity_data is QuantityData:
			if quantity_data.name == key:
				return quantity_data.duplicate()
	return null

func ad_container_quantity(key : String, quantity : float) -> void:
	var quantity_data : QuantityData = get_container_data(key)
	quantity_data.quantity += quantity


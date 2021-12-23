extends Node

export(Resource) var quantity_data : Resource
export(float) var start : float 
export(float) var rate : float

var container : ContainerData = ContainerData.new()

func _physics_process(delta):
	if quantity_data is QuantityData:
		var local_quantity = quantity_data.duplicate()
		local_quantity.quantity = rate * delta
		container.add_content(local_quantity)

func _ready():
	if quantity_data is QuantityData:
		var local_quantity = quantity_data.duplicate()
		local_quantity.quantity = start
		container.add_content(local_quantity)

func get_quantity() -> float:
	if quantity_data is QuantityData:
		var container_quantity = container.find_content(quantity_data.name)
		return container_quantity.quantity
	return 0.0

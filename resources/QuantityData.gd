class_name QuantityData
extends UnitData

export(String) var measure
export(float) var quantity = 0.0

func _to_string():
	return "%s, %f %s" % [._to_string(), quantity, measure]

func add_quantity(value:float):
	if value == null or value == 0.0:
		return
	quantity += value

func split(value:float) -> QuantityData:
	if quantity <= 0 or value <= 0:
		print("Error: Splitting only supports positive quantities.")
		return null
	var split_quantity = duplicate()
	if value == null or value == 0.0:
		split_quantity.quantity = 0
		return split_quantity
	value = min(value, quantity)
	add_quantity(-value)
	split_quantity.quantity = value
	return split_quantity

func copy_from(value : UnitData):
	if value == null:
		return
	if value.has_method('set_quantity'):
		quantity = value.quantity
	.copy_from(value)

func add(value, conserve_quantities:bool=true):
	if not is_instance_valid(value):
		return
	if not value.has_method('set_quantity'):
		print("Error: Adding incompatible types ", str(value), " and ", str(self))
		return
	if value.name != name:
		print("Error: Adding incompatible quantities ", str(value), " and ", str(self))
		return
	add_quantity(value.quantity)
	if conserve_quantities:
		value.quantity = 0

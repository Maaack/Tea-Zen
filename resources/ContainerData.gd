class_name ContainerData
extends Resource

const TOTAL_QUANTITY = 'Total Quantity'

export(Array, Resource) var contents : Array setget set_contents

var _quantities : Array = [] setget set_quantities, get_quantities
var _total : QuantityData

func _to_string():
	var to_string = "%s: [" % ._to_string()
	for content in contents:
		to_string += str(content) + ","
	return to_string + "]"

func _get_duplicated_unit_data(array:Array):
	var duplicated_unit_data : Array = []
	for unit in array:
		if unit is UnitData:
			duplicated_unit_data.append(unit.duplicate())
	return duplicated_unit_data

func set_contents(value:Array):
	if value == null:
		return
	contents = _get_duplicated_unit_data(value)
	update_quantities()

func set_quantities(values : Array):
	# _quantities should only be set internally
	pass

func get_quantities() -> Array:
	return _quantities

func _reset_quantities():
	if _total == null:
		_total = QuantityData.new()
		_total.name = TOTAL_QUANTITY
	_total.quantity = 0
	for quantity in _quantities:
		if quantity is QuantityData:
			quantity.quantity = 0

func update_quantities():
	_reset_quantities()
	for content in contents:
		if content is UnitData:
			add_to_quantity(content)
			add_to_total(content)

func _get_quantity_to_add(content:UnitData):
	if content is QuantityData:
		return content.quantity
	return 1

func add_to_quantity(content:UnitData):
	var quantity_to_add = _get_quantity_to_add(content)
	var quantity : QuantityData
	quantity = find_quantity(content.name)
	if quantity:
		quantity.quantity += quantity_to_add
	else:
		quantity = QuantityData.new()
		quantity.copy_from(content)
		quantity.quantity = quantity_to_add
		_quantities.append(quantity)
	return quantity

func add_to_total(content:UnitData):
	var quantity_to_add = _get_quantity_to_add(content)
	_total.quantity += quantity_to_add

func add_contents(values):
	if values == null:
		return
	if not values is Array:
		values = [values]
	for value in values:
		add_content(value)
	return contents

func add_content(value : UnitData):
	if value == null:
		return
	if value is QuantityData:
		var current_unit = find_content(value.name)
		if current_unit is QuantityData:
			current_unit.quantity += value.quantity
		else:
			contents.append(value.duplicate())
	else:
		contents.append(value.duplicate())
	update_quantities()
	return contents

func remove_contents(values):
	if values == null:
		return
	if not values is Array:
		values = [values]
	for value in values:
		remove_content(value)

func remove_content(value:UnitData):
	if value == null:
		return
	if value is QuantityData:
		var content = find_content(value.name)
		if content is QuantityData:
			content.quantity -= value.quantity
			update_quantities()
			return
	var index = contents.find(value)
	if index >= 0:
		contents.remove(index)
		update_quantities()

func find_quantity(name_query:String):
	for quantity in _quantities:
		if quantity is QuantityData and quantity.name == name_query:
			return quantity

func find_content(name_query:String):
	for content in contents:
		if content is UnitData and content.name == name_query:
			return content

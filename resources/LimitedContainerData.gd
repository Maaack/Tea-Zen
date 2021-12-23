class_name LimitedContainerData
extends ContainerData

const LIMIT_QUANTITY = 'Limit Quantity'

export(int,0,16384) var int_limit = 0 setget set_int_limit

var _limit : QuantityData

func set_int_limit(value:int):
	int_limit = value
	if value == null:
		_limit = null
		return
	_limit = QuantityData.new()
	_limit.name = LIMIT_QUANTITY
	_limit.quantity = value

func get_empty_space():
	if _limit == null:
		return
	return (_limit.quantity - _total.quantity)

func add_content(value : UnitData):
	var quantity_to_add = _get_quantity_to_add(value)
	var empty_space = get_empty_space()
	if empty_space != null and empty_space < quantity_to_add:
		return
	return .add_content(value)


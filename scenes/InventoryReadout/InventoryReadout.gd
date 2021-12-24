tool
extends VBoxContainer

const INVENTORY_STRING = "%.2f %s"

export(Resource) var quantity_type : Resource
export(NodePath) var inventory_node_path : NodePath
export(String) var name_override : String

onready var inventory_node = get_node(inventory_node_path)

func _process(delta):
	if not quantity_type is QuantityData:
		return
	var quantity_data : QuantityData
	if inventory_node.get('container'):
		quantity_data = inventory_node.container.find_content(quantity_type.name)
	if quantity_data == null:
		quantity_data = quantity_type.duplicate()
		quantity_data.quantity = 0.0
	if name_override != "":
		$NameLabel.text = name_override
	else:
		$NameLabel.text = quantity_data.name
	$QuantityLabel.text = INVENTORY_STRING % [quantity_data.quantity, quantity_data.measure]

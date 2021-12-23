tool
extends Control

const INVENTORY_STRING = "%.2f %s"
export(String) var inventory_name : String = 'Inventory Name' setget set_inventory_name
export(String) var inventory_measure : String = 'Kg/L' setget set_inventory_measure
export(float) var inventory_quantity : float = 0.0 setget set_inventory_quantity

func _clear_buttons() -> void:
	for child in $ButtonContainer.get_children():
		child.queue_free()

func set_inventory_name(value : String) -> void:
	inventory_name = value
	$NameLabel.text = inventory_name

func set_inventory_measure(value : String) -> void:
	inventory_measure = value
	$QuantityLabel.text = INVENTORY_STRING % [inventory_quantity, inventory_measure]

func set_inventory_quantity(value : float) -> void:
	inventory_quantity = value
	$QuantityLabel.text = INVENTORY_STRING % [inventory_quantity, inventory_measure]


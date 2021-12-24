tool
extends Control

const STOCK_STRING = "%.2f %s"
export(Resource) var quantity_data : Resource setget set_quantity_data

func _clear_buttons() -> void:
	for child in $ButtonContainer.get_children():
		child.queue_free()

func set_quantity_data(value : QuantityData) -> void:
	quantity_data = value
	$HBoxContainer/StockNameLabel.text = quantity_data.name
	$HBoxContainer/StockQuanityLabel.text = STOCK_STRING % [quantity_data.quantity, quantity_data.measure]
	
func show_buttons() -> void:
	$HBoxContainer/MarginContainer/ButtonContainer.show()

func hide_buttons() -> void:
	$HBoxContainer/MarginContainer/ButtonContainer.hide()

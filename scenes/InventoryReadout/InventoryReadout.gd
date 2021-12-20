tool
extends Control

const STOCK_STRING = "%.1f %s"
export(String) var stock_name : String = 'Stock Name' setget set_stock_name
export(String) var stock_measure : String = 'Kg/L' setget set_stock_measure
export(float) var stock_quantity : float = 0.0 setget set_stock_quantity

func _clear_buttons() -> void:
	for child in $ButtonContainer.get_children():
		child.queue_free()

func set_stock_name(value : String) -> void:
	stock_name = value
	$StockNameLabel.text = stock_name

func set_stock_measure(value : String) -> void:
	stock_measure = value
	$StockQuantityLabel.text = STOCK_STRING % [stock_quantity, stock_measure]

func set_stock_quantity(value : float) -> void:
	stock_quantity = value
	$StockQuantityLabel.text = STOCK_STRING % [stock_quantity, stock_measure]


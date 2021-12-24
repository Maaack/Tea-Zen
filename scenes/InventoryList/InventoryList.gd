tool
extends VBoxContainer

export(NodePath) var inventory_node_path : NodePath

onready var inventory_node = get_node(inventory_node_path)

var inventory_item_scene : PackedScene = preload("res://scenes/InventoryItem/InventoryItem.tscn")
var inventory_item_map : Dictionary = {}

func get_inventory_item(key : String):
	if key in inventory_item_map:
		return inventory_item_map[key]
	var inventory_item_instance = inventory_item_scene.instance()
	add_child(inventory_item_instance)
	inventory_item_map[key] = inventory_item_instance
	return inventory_item_instance

func _update_list() -> void:
	if inventory_node is Node and inventory_node.get('container'):
		var container_data : ContainerData = inventory_node.container
		for quantity_data in container_data.get_quantities():
			var inventory_item = get_inventory_item(quantity_data.name)
			inventory_item.quantity_data = quantity_data

func _process(delta):
	_update_list()

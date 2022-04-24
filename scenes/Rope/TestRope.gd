extends Node2D


func _attach_children():
	var prev_child_node : PhysicsBody2D
	for child_node in get_children():
		if child_node is RopePhysicsBody and prev_child_node:
			child_node.attached_to_path = prev_child_node.get_path()
		if child_node is PhysicsBody2D:
			prev_child_node = child_node

func _ready():
	_attach_children()

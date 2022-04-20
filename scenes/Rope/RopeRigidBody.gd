tool
class_name RopePhysicsBody
extends PhysicsBody2D

export(NodePath) var attached_to_path : NodePath setget set_attached_to_path

func set_attached_to_path(node_path : NodePath) -> void:
	attached_to_path = node_path
	if attached_to_path == "":
		return
	$PinJoint2D.node_a = attached_to_path

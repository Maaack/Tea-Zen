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

func _disable_collisions() -> void :
	$TeaTagRigidBody.collision_layer = 0
	$TeaBagRigidBody.collision_layer = 0
	$TeaBagRigidBody.collision_mask = 0

func set_tea(tea_data : TeaData) -> void :
	#$TeaBagRigidBody/Sprite.texture = tea_data.bag_image
	$TeaTagFront.texture = tea_data.tag_image

func set_move_to_target(current_target : Vector2) -> void :
	$TeaTagRigidBody.move_to_target = current_target

func _process(_delta):
	$TeaTagFront.position = $TeaTagRigidBody.position

func delete():
	_disable_collisions()
	$TeaTagRigidBody.following_mouse = false
	$AnimationPlayer.play("FadeOut")

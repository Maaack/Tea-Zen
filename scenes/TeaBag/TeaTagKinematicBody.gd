extends KinematicBody2D

export(float) var speed : float = 100.0

var target = Vector2()
var velocity = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		target = event.position

func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	# look_at(target)
	if pow(position.distance_to(target), 2) > speed:
		
		velocity = move_and_slide(velocity)
	else:
		position = target

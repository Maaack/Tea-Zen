extends RigidBody2D

export(float) var speed : float = 5.0
export(float) var max_velocity : float = 250.0
export(Vector2) var mouse_offset : Vector2 = Vector2.ZERO
export(bool) var negate_current_velocity : bool = true

var move_to_target = Vector2()
var velocity = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		move_to_target = event.position + mouse_offset

func _integrate_forces(state):
	var vector = move_to_target - state.transform.origin
	vector *= speed
	vector = vector.clamped(max_velocity)
	if negate_current_velocity:
		vector -= state.linear_velocity
	apply_central_impulse(vector)

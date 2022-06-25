extends RigidBody2D

export(float) var speed : float = 5.0
export(float) var max_velocity : float = 250.0
export(Vector2) var mouse_offset : Vector2 = Vector2.ZERO
export(bool) var negate_current_velocity : bool = true
export(bool) var following_mouse : bool = true

var move_to_target = Vector2()
var velocity = Vector2()

func _follow_mouse(state):
	var vector : Vector2 = move_to_target - state.transform.origin
	vector *= speed
	vector = vector.limit_length(max_velocity)
	if negate_current_velocity:
		vector -= state.linear_velocity
	apply_central_impulse(vector)
	

func _input(event):
	if event is InputEventMouseMotion and following_mouse:
		move_to_target = event.position + mouse_offset

func _integrate_forces(state):
	if not following_mouse:
		return
	var vector = move_to_target - state.transform.origin
	vector *= speed
	vector = vector.limit_length(max_velocity)
	if negate_current_velocity:
		vector -= state.linear_velocity
	apply_central_impulse(vector)

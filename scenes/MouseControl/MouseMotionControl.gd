extends Control

signal force_applied(position, vector)
signal force_released(position)

export(float, 0.0, 100.0) var minimum_vector : float = 5.0
var mouse_position : Vector2
var mouse_vector : Vector2

func _gui_input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		mouse_vector = event.relative
		if mouse_vector.length() < minimum_vector:
			emit_signal("force_released", mouse_position / rect_size)
		else:
			var relative_mouse_position : Vector2 = (mouse_position) / rect_size
			emit_signal("force_applied", relative_mouse_position, mouse_vector)

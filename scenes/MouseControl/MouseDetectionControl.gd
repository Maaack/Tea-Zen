extends Control

signal force_applied(position, vector)
signal force_released(position)

var mouse_position : Vector2
var mouse_vector : Vector2

func _gui_input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		mouse_vector = event.relative
	else: 
		mouse_vector = Vector2.ZERO
	var relative_mouse_position : Vector2 = (mouse_position) / rect_size
	emit_signal("force_applied", relative_mouse_position, mouse_vector)

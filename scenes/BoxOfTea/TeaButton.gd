tool
extends Button

signal tea_selected(tea_data)
signal tea_hovered(tea_data)

export(Resource) var tea : Resource setget set_tea

func set_tea(tea_data : TeaData) -> void :
	tea = tea_data

func _on_TeaButton_mouse_entered():
	emit_signal("tea_hovered", tea)

func _on_TeaButton_button_down():
	emit_signal("tea_selected", tea)

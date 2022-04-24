tool
extends Control

signal pressed(tea_data)

export(Resource) var tea : Resource setget set_tea

func set_tea(tea_data : TeaData) -> void :
	tea = tea_data
	$TextureButton.texture_normal = tea.tag_image
	$TextureButton.texture_pressed = tea.tag_image

func _on_TextureButton_pressed():
	emit_signal("pressed", tea)

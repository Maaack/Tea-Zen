extends Node2D

signal tea_selected(tea_data)

export(bool) var disabled : bool = true setget set_disabled

onready var wrapper_nodes_array : Array = [
	$BlueberryTeaBagWrapper,
	$MintTeaBagWrapper,
	$ChamomileTeaBagWrapper,
	$RoseTeaBagWrapper,
	$ElderberryTeaBagWrapper
]
var currently_picked_up_tea: Node2D

func set_disabled(value : bool) -> void:
	disabled = value
	for child in $Control/HBoxContainer.get_children():
		if child is Button:
			child.disabled = value
			if value:
				child.mouse_default_cursor_shape = Button.CURSOR_ARROW
			else:
				child.mouse_default_cursor_shape = Button.CURSOR_POINTING_HAND
	if value:
		_drop_current_tea()

func _drop_current_tea() -> void:
	if is_instance_valid(currently_picked_up_tea):
		if currently_picked_up_tea.has_method("drop_down"):
			currently_picked_up_tea.drop_down()

func _pick_up_tea(tea_data : TeaData):
	for node in wrapper_nodes_array:
		if node.tea == tea_data and node.has_method("pick_up"):
			node.pick_up()
			currently_picked_up_tea = node

func _tear_open_tea(tea_data : TeaData):
	for node in wrapper_nodes_array:
		if node.tea == tea_data and node.has_method("tear_open"):
			node.tear_open()

func _on_TeaButton_tea_selected(tea_data):
	_tear_open_tea(tea_data)
	emit_signal("tea_selected", tea_data)

func _on_TeaButton_tea_hovered(tea_data):
	if disabled:
		return
	_drop_current_tea()
	_pick_up_tea(tea_data)

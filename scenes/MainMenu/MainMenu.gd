extends Node

enum States{
	MENU,
	CREDITS,
	OPTIONS,
	EXIT
}

var steeping_tea : bool = true setget set_steeping_tea
var dye_brush_position : Vector2 = Vector2(0.5, 0.0)
var velocity_brush_position : Vector2 = Vector2(0.5, 0.5) setget set_velocity_brush_position
var menu_state : int = States.MENU

func set_steeping_tea(value : bool) -> void:
	steeping_tea = value
	
func set_velocity_brush_position(value : Vector2) -> void:
	velocity_brush_position = value

func _disable_menu_buttons(disabled : bool = true) -> void:
	$Control/CenterMarginContainer/CenterContainer/VBoxContainer/StartButton.disabled = disabled
	$Control/CenterMarginContainer/CenterContainer/VBoxContainer/OptionsButton.disabled = disabled
	$Control/CenterMarginContainer/CenterContainer/VBoxContainer/CreditsButton.disabled = disabled
	$Control/CenterMarginContainer/CenterContainer/VBoxContainer/QuitButton.disabled = disabled

func open_menu():
	menu_state = States.MENU
	_disable_menu_buttons(false)

func close_menu():
	_disable_menu_buttons()

func _process(delta):
	var brush_offset : Vector2 = Vector2.ZERO
	if steeping_tea:
		brush_offset += Vector2(rand_range(-0.02, 0.02), 0.0)
		$FluidSimulator.apply_velocity_force(velocity_brush_position + brush_offset, Vector2.ZERO)
	$FluidSimulator.apply_dye_paint(dye_brush_position + brush_offset, Vector2.ZERO)

func quit():
	close_menu()
	menu_state = States.EXIT
	$MenuAnimationPlayer.play("Outro")
	yield($MenuAnimationPlayer, "animation_finished")
	get_tree().quit()

func _on_QuitButton_pressed():
	quit()

func _on_StartButton_pressed():
	menu_state = States.EXIT
	$BrushAnimationPlayer.stop()
	$PanningTeaAnimationPlayer.stop()
	$MenuAnimationPlayer.play("Outro")
	yield($MenuAnimationPlayer, "animation_finished")
	if PersistentData.first_version_played == PersistentData.UNKNOWN_VERSION:
		get_tree().change_scene("res://scenes/PreviousPlayCheck/PreviousPlayCheck.tscn")
		return
	get_tree().change_scene("res://scenes/DemoScene/DemoScene.tscn")

func _apply_force_to_sim(position : Vector2, vector : Vector2, sprite_node : Sprite) -> void:
	vector *= 0.04
	vector.y = clamp(vector.y, 0.1, 4.0)
	position.y /= 4
	position.y += sprite_node.region_rect.position.y / sprite_node.texture.get_size().y
	$FluidSimulator.apply_velocity_force_2(position, vector)

func open_credits():
	close_menu()
	menu_state = States.CREDITS
	$MenuAnimationPlayer.play("OpenCredits")

func close_credits():
	$MenuAnimationPlayer.play("CloseCredits")

func open_options():
	close_menu()
	menu_state = States.OPTIONS
	$MenuAnimationPlayer.play("OpenOptions")

func close_options():
	$MenuAnimationPlayer.play("CloseOptions")

func _on_MouseMotionControl_force_released(position):
	$FluidSimulator.release_velocity_force_2()

func _on_TopMouseMotionControl_force_applied(position, vector):
	_apply_force_to_sim(position, vector, $Control/Node2D/Sprite)

func _on_BottomMouseMotionControl_force_applied(position, vector):
	_apply_force_to_sim(position, vector, $Control/Node2D/Sprite2)

func _on_CreditsButton_pressed():
	open_credits()

func _on_Credits_end_reached():
	close_credits()

func _on_OptionsButton_pressed():
	open_options()

func _on_BackButton_pressed():
	$Control/BackButton.disabled = true
	match(menu_state):
		States.CREDITS:
			close_credits()
		States.OPTIONS:
			close_options()

func _on_MusicController_pause_pressed():
	$AudioStreamPlayer.stream_paused = true

func _on_MusicController_play_pressed():
	$AudioStreamPlayer.stream_paused = false

func _on_MusicController_repeat_pressed():
	$AudioStreamPlayer.play()

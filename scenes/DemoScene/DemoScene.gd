extends Node


export(int, 0, 15) var show_skip_time : int = 1
export(int, 0, 15) var wait_time : int = 8
export(float) var first_skip_point : float = 29.3

var dragging_tea_bag : bool = false
var started_steeping : bool = false 

func _started_steeping():
	started_steeping = true
	$Control/Timer.start()
	$MusicAudioStreamPlayer.play()
	$DemoAnimationPlayer.play("Steeping")

func _host_returned():
	dragging_tea_bag = false
	$HeldTeaBag.hide()
	$DemoAnimationPlayer.play("ReturnOfHost")

func back_to_main_menu():
	get_tree().change_scene("res://scenes/MainMenu/MainMenu.tscn")

func pick_up_teabag():
	$Control/TeaBagButton.hide()
	$HeldTeaBag.show()
	dragging_tea_bag = true

func _on_MouseDetectionControl_force_applied(position, vector):
	if not dragging_tea_bag:
		return
	vector.y += 1.0
	vector *= 0.1
	$FluidSimulator.apply_velocity_force(position, vector, true)
	if not started_steeping:
		_started_steeping()

func _input(event):
	if event is InputEventMouseMotion:
		if dragging_tea_bag:
			$HeldTeaBag.position = event.position

func _on_MouseDetectionControl_mouse_exited():
	$FluidSimulator.release_velocity_force(true)

func _on_Timer_minute_passed(minute):
	if minute == show_skip_time:
		$Control/Timer.show_next_button()
	elif minute == wait_time:
		_host_returned()

func _on_SkipButton_pressed():
	if $DemoAnimationPlayer.current_animation == "ReturnOfHost":
		back_to_main_menu()
	elif $DemoAnimationPlayer.current_animation == "Intro" and \
		$DemoAnimationPlayer.current_animation_position < first_skip_point:
		$DemoAnimationPlayer.seek(first_skip_point)
	elif $DemoAnimationPlayer.current_animation == "Steeping":
		_host_returned()

func _on_TeaBagButton_button_down():
	pick_up_teabag()

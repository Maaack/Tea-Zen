extends Node


export(int, 0, 15) var wait_time : int = 8
var dragging_tea_bag : bool = false
var started_steeping : bool = false 

func _started_steeping():
	started_steeping = true
	$Control/Timer.start()
	$MusicAudioStreamPlayer.play()
	$DemoAnimationPlayer.play("Steeping")

func _host_returned():
	dragging_tea_bag = false
	$StrawberryTeaBag.hide()
	$DemoAnimationPlayer.play("ReturnOfHost")
		

func back_to_main_menu():
	get_tree().change_scene("res://scenes/MainMenu/MainMenu.tscn")

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
			$StrawberryTeaBag.position = event.position

func _on_MouseDetectionControl_mouse_exited():
	$FluidSimulator.release_velocity_force(true)


func _on_Timer_minute_passed(minute):
	if minute == wait_time:
		_host_returned()

func _on_SkipButton_pressed():
	if $HostReturnsAudioStreamPlayer.playing:
		back_to_main_menu()
	elif $DemoAnimationPlayer.is_playing() and \
	$DemoAnimationPlayer.current_animation == "Intro" and \
	$HostWelcomeAudioStreamPlayer.playing:
		$DemoAnimationPlayer.seek(29.4)
	elif $MusicAudioStreamPlayer.playing:
		_host_returned()


func _on_TeaBagButton_button_down():
	$Control/TeaBagButton.hide()
	dragging_tea_bag = true

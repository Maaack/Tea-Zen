extends Node


export(int, 0, 15) var show_skip_time : int = 1
export(int, 0, 15) var wait_time : int = 8
export(float) var first_skip_point : float = 29.3
export(Array, Resource) var assorted_teas_array : Array

var dragging_tea_bag : bool = false
var started_steeping : bool = false
var steeping_state : bool = false
var steeped_time : float = 0.0
var current_tea : int = -1

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
	current_tea += 1
	if current_tea >= assorted_teas_array.size():
		current_tea %= assorted_teas_array.size()
	var current_tea_data : TeaData = assorted_teas_array[current_tea] 
	$HeldTeaBag.show()
	$HeldTeaBag.texture = current_tea_data.bag_image
	$FluidSimulator.set_brush_color(current_tea_data.color)
	dragging_tea_bag = true


func _on_MouseDetectionControl_force_applied(position, vector):
	if not dragging_tea_bag:
		return
	steeping_state = true
	vector.y += 1.0
	vector *= 0.1
	$FluidSimulator.apply_velocity_force(position, vector, true)
	if not started_steeping:
		_started_steeping()

func _input(event):
	if event is InputEventMouseMotion:
		$HeldTeaBag.position = event.position

func _on_MouseDetectionControl_mouse_exited():
	$FluidSimulator.release_velocity_force(true)
	steeping_state = false

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

func _process(delta):
	if steeping_state:
		steeped_time += delta

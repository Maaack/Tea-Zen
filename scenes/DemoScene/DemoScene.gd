extends Node

const ANIMATION_STEEPED_ALL = "SteepedEveryFlavor"
const ANIMATION_NO_STEEP = "NoSteep"
const ANIMATION_LIGHT_STEEP = "LightSteep"
const ANIMATION_LONG_STEEP = "LongSteep"
const ANIMATION_WELL_STEEPED = "WellSteeped"

export(int, 0, 15) var show_skip_time : int = 1
export(int, 0, 15) var wait_time : int = 8
export(float) var first_skip_point : float = 29.3
export(Vector2) var velocity_base : Vector2 = Vector2(0.0, 1.0)
export(float) var velocity_mod : float = 0.002

var dragging_tea_bag : bool = false
var started_steeping : bool = false
var steeping_state : bool = false
var tea_steep_times : Dictionary = {}
var animation_queue : Array = []
var tea_bag_on_string_scene : PackedScene = preload("res://scenes/TeaBag/TeaBagOnString.tscn")
var current_tea_bag_instance : Node2D
var current_tea_data : TeaData
var steeping_tea_bag

func _started_steeping():
	started_steeping = true
	$Control/Timer.start()
	$AudioStreamPlayers/Music.play()
	$Control/BordersMarginContainer/Control/MusicController.show_controls()
	$DemoAnimationPlayer.play("Steeping")

func _host_returned():
	dragging_tea_bag = false
	$DemoAnimationPlayer.play("ReturnOfHost")

func _open_tea_box():
	if $Control/BagOfTeas/TeaTagButtons/AnimationPlayer.is_playing():
		$Control/BagOfTeas/TeaTagButtons/AnimationPlayer.seek(1.5)
	else:
		$Control/BagOfTeas/TeaTagButtons/AnimationPlayer.play("OpenBox")
	
func back_to_main_menu():
	get_tree().change_scene("res://scenes/MainMenu/MainMenu.tscn")


func delete_current_teabag():
	if is_instance_valid(current_tea_bag_instance):
		current_tea_bag_instance.delete()

func pick_up_teabag(tea_data : TeaData):
	delete_current_teabag()
	current_tea_data = tea_data
	var tea_bag_on_string_instance = tea_bag_on_string_scene.instance()
	add_child(tea_bag_on_string_instance)
	tea_bag_on_string_instance.set_tea(current_tea_data)
	tea_bag_on_string_instance.position = $Control.get_global_mouse_position()
	tea_bag_on_string_instance.set_move_to_target($Control.get_global_mouse_position())
	$FluidSimulator.set_brush_color(current_tea_data.color)
	current_tea_bag_instance = tea_bag_on_string_instance
	dragging_tea_bag = true

func _queue_tea_outcome_animations() -> void:
	if tea_steep_times.size() == 5:
		animation_queue.append(ANIMATION_STEEPED_ALL)
		return
	var tea_name_1 : String = ""
	var tea_name_2 : String = ""
	var steep_time_1 : float = 0.0
	var steep_time_2 : float = 0.0
	var steep_time_total : float = 0.0
	for tea_name in tea_steep_times:
		var steeped_time : float = tea_steep_times[tea_name]
		if steeped_time > steep_time_1:
			# This is the strongest tea
			tea_name_2 = tea_name_1
			tea_name_1 = tea_name
			steep_time_2 = steep_time_1
			steep_time_1 = steeped_time
		elif steeped_time > steep_time_2:
			# This is the 2nd strongest tea
			tea_name_2 = tea_name
			steep_time_2 = steeped_time
		steep_time_total += steeped_time
	if tea_steep_times.size() == 1 and steep_time_total < 5.0:
		animation_queue.append(ANIMATION_NO_STEEP)
		return
	animation_queue.append("Strong%sFlavor" % tea_name_1)
	if tea_name_2 != "":
		animation_queue.append("Lighter%sFlavor" % tea_name_2)
	if steep_time_total < 30:
		animation_queue.append(ANIMATION_LIGHT_STEEP)
	elif steep_time_total > 70:
		animation_queue.append(ANIMATION_LONG_STEEP)
	else:
		animation_queue.append(ANIMATION_WELL_STEEPED)
	

func taste_tea() -> void:
	_queue_tea_outcome_animations()
	while animation_queue.size() > 0:
		if $DemoAnimationPlayer.is_playing():
			yield($DemoAnimationPlayer, "animation_finished")
		$DemoAnimationPlayer.play(animation_queue.pop_front())
		yield($DemoAnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(1.0), "timeout")
	$DemoAnimationPlayer.play("EndOfDemo")

func _steep_tea():
	if not dragging_tea_bag:
		return
	var position : Vector2 = ((current_tea_bag_instance.position + steeping_tea_bag.position - $Area2D.position) + $Area2D/CollisionShape2D.shape.extents) / ($Area2D/CollisionShape2D.shape.extents * 2)
	var vector : Vector2 = steeping_tea_bag.linear_velocity
	vector += velocity_base
	vector *= velocity_mod
	$FluidSimulator.apply_velocity_force(position, vector, true)
	if not started_steeping:
		_started_steeping()

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
	_open_tea_box()

func _add_steeping_time(seconds : float) -> void:
	var tea_name : String = current_tea_data.name
	if not tea_name in tea_steep_times:
		tea_steep_times[tea_name] = 0.0
	tea_steep_times[tea_name] += seconds

func _process(delta):
	if steeping_state:
		_steep_tea()
		_add_steeping_time(delta)

func _on_Area2D_body_entered(body : TeaBagRigidBody):
	steeping_state = true
	steeping_tea_bag = body

func _on_Area2D_body_exited(body):
	steeping_state = false
	steeping_tea_bag = null

func _on_TeaTagButton_pressed(tea_data):
	_open_tea_box()
	pick_up_teabag(tea_data)

func _on_MusicController_pause_pressed():
	$AudioStreamPlayers/Music.stream_paused = true

func _on_MusicController_play_pressed():
	$AudioStreamPlayers/Music.stream_paused = false

func _on_MusicController_repeat_pressed():
	$AudioStreamPlayers/Music.play()

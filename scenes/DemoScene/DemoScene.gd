extends Node


export(int, 0, 15) var show_skip_time : int = 1
export(int, 0, 15) var wait_time : int = 8
export(float) var first_skip_point : float = 29.3
export(Array, Resource) var assorted_teas_array : Array
export(Vector2) var velocity_base : Vector2 = Vector2(0.0, 1.0)
export(float) var velocity_mod : float = 0.002

var dragging_tea_bag : bool = false
var started_steeping : bool = false
var steeping_state : bool = false
var steeped_time : float = 0.0
var current_tea : int = -1

var tea_bag_on_string_scene : PackedScene = preload("res://scenes/TeaBag/TeaBagOnString.tscn")
var current_tea_bag_instance : Node2D

var steeping_tea_bag

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
	if is_instance_valid(current_tea_bag_instance):
		current_tea_bag_instance.queue_free()
	var tea_bag_on_string_instance = tea_bag_on_string_scene.instance()
	add_child(tea_bag_on_string_instance)
	tea_bag_on_string_instance.set_tea(current_tea_data)
	tea_bag_on_string_instance.position = $Control.get_global_mouse_position()
	tea_bag_on_string_instance.set_move_to_target($Control.get_global_mouse_position())
	$FluidSimulator.set_brush_color(current_tea_data.color)
	current_tea_bag_instance = tea_bag_on_string_instance
	dragging_tea_bag = true

func _steep_tea():
	if not dragging_tea_bag:
		return
	var position : Vector2 = (current_tea_bag_instance.position + steeping_tea_bag.position - $Area2D.position) / ($Area2D/CollisionShape2D.shape.extents * 2)
	var vector : Vector2 = steeping_tea_bag.linear_velocity
	vector += velocity_base
	vector *= velocity_mod
	$FluidSimulator.apply_velocity_force(position, vector, true)
	if not started_steeping:
		_started_steeping()

func _on_MouseDetectionControl_force_applied(position, vector):
	pass

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
		_steep_tea()
		steeped_time += delta

func _on_Area2D_body_entered(body : TeaBagRigidBody):
	steeping_state = true
	steeping_tea_bag = body

func _on_Area2D_body_exited(body):
	steeping_state = false
	steeping_tea_bag = null

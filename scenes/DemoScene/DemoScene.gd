extends Node

const ANIMATION_STEEPED_ALL = "SteepedEveryFlavor"
const ANIMATION_NO_STEEP = "NoSteep"
const ANIMATION_LIGHT_STEEP = "LightSteep"
const ANIMATION_LONG_STEEP = "LongSteep"
const ANIMATION_WELL_STEEPED = "WellSteeped"

enum DEMO_PHASES{
	NONE,
	INTRO,
	WAITING,
	STEEPING,
	RETURN,
	EVALUATION,
	CONCLUSION
}

export(int, 0, 15) var show_skip_time : int = 1
export(int, 0, 15) var wait_time : int = 8
export(Vector2) var velocity_base : Vector2 = Vector2(0.0, 1.0)
export(float) var velocity_mod : float = 0.002
export(DEMO_PHASES) var current_phase : int = DEMO_PHASES.NONE setget set_current_phase

var dragging_tea_bag : bool = false
var started_steeping : bool = false
var steeping_state : bool = false
var tea_steep_times : Dictionary = {}
var animation_queue : Array = []
var tea_bag_on_string_scene : PackedScene = preload("res://scenes/TeaBag/TeaBagOnString.tscn")
var current_tea_bag_instance : Node2D
var current_tea_data : TeaData
var steeping_tea_bag
var animation_state_machine : AnimationNodeStateMachinePlayback

func set_current_phase(value : int) -> void:
	if current_phase > value:
		return
	current_phase = value
	
func _ready():
	var show_first_intro : bool = false
	var show_second_intro : bool = false
	var show_many_intro : bool = false
	var show_many_more_intro : bool = false
	var show_first_return : bool = false
	var show_second_return : bool = false
	var show_third_return : bool = false
	var show_first_outro : bool = false
	var show_second_outro : bool = false
	var show_third_outro : bool = false
	var show_fourth_outro : bool = false
	# Intros
	if PersistentData.remembered_intros >= 2:
		$Control/SkipButton.show()
	if PersistentData.remembered_intros >= 10:
		show_many_more_intro = true
	elif PersistentData.remembered_intros >= 4:
		show_many_intro = true
	elif PersistentData.remembered_intros >= 1:
		show_second_intro = true
	else:
		show_first_intro = true
	# Returns
	if PersistentData.remembered_returns >= 2:
		show_third_return = true
	elif PersistentData.remembered_returns >= 1:
		show_second_return = true
	else:
		show_first_return = true
	# Outros
	if PersistentData.remembered_outros >= 6:
		show_fourth_outro = true
	elif PersistentData.remembered_outros >= 5:
		show_third_outro = true
	elif PersistentData.remembered_outros >= 1:
		show_second_outro = true
	else:
		show_first_outro = true
	$AnimationTree['parameters/conditions/intro_first'] = show_first_intro
	$AnimationTree['parameters/conditions/intro_second'] = show_second_intro
	$AnimationTree['parameters/conditions/intro_many'] = show_many_intro
	$AnimationTree['parameters/conditions/intro_many_more'] = show_many_more_intro
	$AnimationTree['parameters/conditions/return_first'] = show_first_return
	$AnimationTree['parameters/conditions/return_second'] = show_second_return
	$AnimationTree['parameters/conditions/return_third'] = show_third_return
	$AnimationTree['parameters/conditions/outro_first'] = show_first_outro
	$AnimationTree['parameters/conditions/outro_second'] = show_second_outro
	$AnimationTree['parameters/conditions/outro_third'] = show_third_outro
	$AnimationTree['parameters/conditions/outro_fourth'] = show_fourth_outro
	animation_state_machine = $AnimationTree["parameters/playback"]

func _started_steeping() -> void:
	started_steeping = true
	$Control/Timer.start()
	$AudioStreamPlayers/Music.play()
	$Control/BordersMarginContainer/Control/MusicController.show_controls()
	animation_state_machine.travel("Steeping")
	PersistentData.played_steeping()

func finished_intro() -> void:
	PersistentData.played_intro()

func finished_return() -> void:
	PersistentData.played_return()

func finished_outro() -> void:
	PersistentData.played_outro()

func _skip_intro() -> void:
	PersistentData.skipped_intro()
	$AnimationTree['parameters/SkipToWaitingHost/conditions/skip_intro_1'] = PersistentData.remembered_skipped_intros == 3
	$AnimationTree['parameters/SkipToWaitingHost/conditions/skip_intro_2'] = PersistentData.remembered_skipped_intros == 6
	$AnimationTree['parameters/SkipToWaitingHost/conditions/skip_intro_3'] = PersistentData.remembered_skipped_intros == 7
	$AnimationTree['parameters/SkipToWaitingHost/conditions/skip_intro_4'] = PersistentData.remembered_skipped_intros == 10
	animation_state_machine.travel("SkipToWaitingHost")

func _host_returned() -> void:
	dragging_tea_bag = false
	animation_state_machine.travel("ReturnOfHostBeforePhase")

func _open_tea_box() -> void:
	if $Control/BagOfTeas/TeaTagButtons/AnimationPlayer.is_playing():
		$Control/BagOfTeas/TeaTagButtons/AnimationPlayer.seek(1.5)
	else:
		$Control/BagOfTeas/TeaTagButtons/AnimationPlayer.play("OpenBox")
	
func back_to_main_menu() -> void:
	get_tree().change_scene("res://scenes/MainMenu/MainMenu.tscn")

func delete_current_teabag() -> void:
	if is_instance_valid(current_tea_bag_instance):
		current_tea_bag_instance.delete()

func pick_up_teabag(tea_data : TeaData) -> void:
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

static func _tea_time_custom_sorter(a, b) -> bool:
	if a[1] > b[1]:
		return true
	return false

func _queue_tea_outcome_animations() -> void:
	if tea_steep_times.size() == 5:
		animation_queue.append(ANIMATION_STEEPED_ALL)
		return
	var tea_time_array : Array = []
	var steep_time_total : float = 0.0
	for tea_name in tea_steep_times:
		var steeped_time : float = tea_steep_times[tea_name]
		tea_time_array.append([tea_name, steeped_time])
		steep_time_total += steeped_time
	tea_time_array.sort_custom(self, "_tea_time_custom_sorter")
	
	if tea_time_array.size() == 1 and steep_time_total < 5.0:
		animation_queue.append(ANIMATION_NO_STEEP)
		return
	animation_queue.append("Strong%sFlavor" % tea_time_array[0][0])
	if tea_time_array.size() > 1:
		animation_queue.append("Lighter%sFlavor" % tea_time_array[1][0])
	if tea_time_array.size() > 2:
		animation_queue.append("HintOf%s" % tea_time_array[2][0])

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
	if current_phase == DEMO_PHASES.EVALUATION:
		animation_state_machine.travel("EndOfDemoBeforePhase")

func _steep_tea() -> void:
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
	match(current_phase):
		DEMO_PHASES.INTRO:
			_skip_intro()
		DEMO_PHASES.STEEPING:
			_host_returned()
		DEMO_PHASES.RETURN:
			animation_state_machine.travel("SkipToHostTastesTea")
		DEMO_PHASES.EVALUATION:
			if animation_queue.empty():
				animation_state_machine.travel("EndOfDemoBeforePhase")
			else:
				animation_queue = []
		DEMO_PHASES.CONCLUSION:
			back_to_main_menu()

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

func _on_Area2D_body_exited(_body):
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

func _on_BoxOfTea_tea_selected(tea_data):
	pick_up_teabag(tea_data)

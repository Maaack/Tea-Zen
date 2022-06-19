tool
extends Node2D

export(Resource) var tea : Resource setget set_tea

func set_tea(value : TeaData) -> void :
	tea = value
	if value != null:
		$WrapperSprite.texture = value.wrapper_image

func drop_down():
	var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	state_machine.travel("DropDown")
	
func pick_up():
	var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	state_machine.travel("PickUp")

func tear_open():
	var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
	state_machine.travel("TearOpen")

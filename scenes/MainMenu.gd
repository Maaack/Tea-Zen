extends Node

var steeping_tea : bool = true setget set_steeping_tea
var dye_brush_position : Vector2 = Vector2(0.5, 0.0)
var velocity_brush_position : Vector2 = Vector2(0.5, 0.5) setget set_velocity_brush_position

func set_steeping_tea(value : bool) -> void:
	steeping_tea = value
	
func set_velocity_brush_position(value : Vector2) -> void:
	velocity_brush_position = value

func _on_MouseControl_force_applied(position, vector):
	$FluidSimulator.apply_dye_paint(position, vector, true)

func _on_MouseControl_force_released(position):
	$FluidSimulator.release_dye_paint(true)

func _process(delta):
	var brush_offset : Vector2 = Vector2.ZERO
	if steeping_tea:
		brush_offset += Vector2(rand_range(-0.02, 0.02), 0.0)
		$FluidSimulator.apply_velocity_force(velocity_brush_position + brush_offset, Vector2.ZERO)
	$FluidSimulator.apply_dye_paint(dye_brush_position + brush_offset, Vector2.ZERO)


func _on_QuitButton_pressed():
	$MenuAnimationPlayer.play("Outro")
	yield($MenuAnimationPlayer, "animation_finished")
	get_tree().quit()


func _on_StartButton_pressed():
	$MenuAnimationPlayer.play("Outro")
	yield($MenuAnimationPlayer, "animation_finished")
	get_tree().change_scene("res://Main.tscn")
	

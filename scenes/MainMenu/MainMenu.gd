extends Node

var steeping_tea : bool = true setget set_steeping_tea
var dye_brush_position : Vector2 = Vector2(0.5, 0.0)
var velocity_brush_position : Vector2 = Vector2(0.5, 0.5) setget set_velocity_brush_position

func set_steeping_tea(value : bool) -> void:
	steeping_tea = value
	
func set_velocity_brush_position(value : Vector2) -> void:
	velocity_brush_position = value

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
	$BrushAnimationPlayer.stop()
	$PanningTeaAnimationPlayer.stop()
	$MenuAnimationPlayer.play("Outro")
	yield($MenuAnimationPlayer, "animation_finished")
	get_tree().change_scene("res://scenes/DemoScene/DemoScene.tscn")

func _on_MouseMotionControl_force_applied(position, vector):
	vector *= 0.01
	vector.y = clamp(vector.y, 0.1, 4.0)
	$FluidSimulator.apply_velocity_force_2(position, vector)

func _on_MouseMotionControl_force_released(position):
	$FluidSimulator.release_velocity_force_2()

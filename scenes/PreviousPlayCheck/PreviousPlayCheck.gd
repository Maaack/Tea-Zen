extends Node

export(String) var version_name : String = "build-"
export(String) var earlier_build_prefix : String = "pre-"

func _ready():
	if PersistentData.first_version_played != PersistentData.UNKNOWN_VERSION:
		continue_scene()

func continue_scene() -> void:
	get_tree().change_scene("res://scenes/DemoScene/DemoScene.tscn")

func _on_YesButton_pressed() -> void:
	PersistentData.set_first_version_played("%s%s" % [earlier_build_prefix, version_name])
	PersistentData.played_intro()
	PersistentData.played_steeping()
	$AnimationPlayer.play("RespondedYes")

func _on_NoButton_pressed() -> void:
	PersistentData.set_first_version_played(version_name)
	$AnimationPlayer.play("RespondedNo")

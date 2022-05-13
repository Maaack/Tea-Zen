extends HBoxContainer

signal pause_pressed
signal play_pressed
signal repeat_pressed

export(String) var song_name : String = "SongName" setget set_song_name

var detect_mouse = false

func set_song_name (value : String) -> void :
	song_name = value
	$MarginContainer/SongName.text = value

func show_controls() -> void :
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	$InactiveTimer.start()
	detect_mouse = true

func _on_RepeatButton_pressed():
	emit_signal("repeat_pressed")

func _on_PauseButton_pressed():
	$PauseButton.hide()
	$PlayButton.show()
	emit_signal("pause_pressed")

func _on_PlayButton_pressed():
	$PlayButton.hide()
	$PauseButton.show()
	emit_signal("play_pressed")

func _on_InactiveTimer_timeout():
	$AnimationPlayer.play("FadeOut")

func _on_MusicController_mouse_entered():
	if not detect_mouse:
		return
	$InactiveTimer.stop()
	if modulate.a != 1.0:
		$AnimationPlayer.play("FastFadeIn")

func _on_MusicController_mouse_exited():
	if not detect_mouse:
		return
	$InactiveTimer.start()

extends Label


signal next_text_displayed(text)
signal last_text_displayed
signal finished_displaying_text

export(float) var base_wait_time = 0.5
export(float) var word_wait_time = 0.05
export(float) var line_wait_time = 2.0
var text_buffer : Array = []
var wait_time : float

func _can_display_next_text():
	return $TextWaitTimer.is_stopped() and $TextClearTimer.is_stopped()

func _display_next_text():
	if text_buffer.size() < 1:
		emit_signal("finished_displaying_text")
		return
	var next_text : String = text_buffer.pop_front()
	percent_visible = 0.0
	text = next_text
	var word_count : int = next_text.split(" ").size()
	wait_time = base_wait_time + (word_wait_time * word_count)
	$Tween.interpolate_property(self, "percent_visible", 0.0, 1.0, wait_time)
	$Tween.start()
	$WriteSoundsPlayer.play("Write")
	$TextWaitTimer.wait_time = wait_time + line_wait_time
	$TextWaitTimer.start()
	emit_signal("next_text_displayed", next_text)

func add_text(value : String):
	text_buffer.append(value)
	if _can_display_next_text():
		_display_next_text()

func _clear_text_and_wait():
	text = ""
	if text_buffer.size() < 1:
		emit_signal("finished_displaying_text")
		return
	$TextClearTimer.start()

func advance_text():
	if $Tween.is_active():
		$Tween.seek($Tween.get_runtime())
	elif not $TextWaitTimer.is_stopped():
		$TextWaitTimer.stop()
		_clear_text_and_wait()
	else:
		_display_next_text()

func _on_TextWaitTimer_timeout():
	_clear_text_and_wait()

func _on_TextClearTimer_timeout():
	_display_next_text()

func _on_Tween_tween_all_completed():
	$WriteSoundsPlayer.stop()
	if text_buffer.size() < 1:
		emit_signal("last_text_displayed")

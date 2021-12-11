extends Control


signal next_text_displayed(text)
signal last_text_displayed
signal finished_displaying_text

export(float) var base_wait_time = 0.5
export(float) var word_wait_time = 0.05
export(float) var line_wait_time = 2.0
var text_buffer : Array = []
var wait_time : float
var _last_label : Label

onready var notes_container = $ScrollContainer/MarginContainer/VBoxContainer

func _can_display_next_text():
	return $TextWaitTimer.is_stopped() and $TextClearTimer.is_stopped()

func _get_new_label():
	if is_instance_valid(_last_label) and _last_label.text == "":
		return _last_label
	_last_label = Label.new()
	_last_label.autowrap = true
	notes_container.add_child(_last_label)
	return _last_label

func _display_next_text():
	if text_buffer.size() < 1:
		emit_signal("finished_displaying_text")
		return
	var next_text : String = text_buffer.pop_front()
	var new_label = _get_new_label()
	new_label.percent_visible = 0.0
	new_label.text = next_text
	var word_count : int = next_text.split(" ").size()
	wait_time = base_wait_time + (word_wait_time * word_count)
	$WritingTween.interpolate_property(new_label, "percent_visible", 0.0, 1.0, wait_time)
	$WritingTween.start()
	$WriteSoundsPlayer.play("Write")
	$TextWaitTimer.wait_time = wait_time + line_wait_time
	$TextWaitTimer.start()
	emit_signal("next_text_displayed", next_text)

func add_text(value : String):
	text_buffer.append(value)
	if _can_display_next_text():
		_display_next_text()

func _clear_text_and_wait():
	_get_new_label()
	if text_buffer.size() < 1:
		emit_signal("finished_displaying_text")
		return
	$TextClearTimer.start()

func advance_text():
	if $WritingTween.is_active():
		$WritingTween.seek($WritingTween.get_runtime())
	elif not $TextWaitTimer.is_stopped():
		$TextWaitTimer.stop()
		_clear_text_and_wait()
	else:
		_display_next_text()

func _on_TextWaitTimer_timeout():
	_clear_text_and_wait()

func _on_TextClearTimer_timeout():
	_display_next_text()

func _on_WritingTween_tween_all_completed():
	$WriteSoundsPlayer.stop()
	if text_buffer.size() < 1:
		emit_signal("last_text_displayed")

func _on_MarginContainer_item_rect_changed():
	if $NewLineTween.is_active():
		return
	var target_scroll = max(0.0, $ScrollContainer/MarginContainer.rect_size.y - $ScrollContainer.rect_size.y)
	$NewLineTween.interpolate_property($ScrollContainer, "scroll_vertical", $ScrollContainer.scroll_vertical, target_scroll, 0.5, Tween.TRANS_CUBIC)
	$NewLineTween.start()

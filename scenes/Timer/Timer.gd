extends Control

signal minute_passed(minute)

enum SecondIncrements{
	ZERO,
	FIFTEEN,
	THIRTY,
	FORTYFIVE
}

var current_second_increment : int = 0
var second_incrementor : int = 1
var current_minute : int = 0

func start() -> void:
	$Clock.start()

func stop() -> void:
	$Clock.stop()

func show_next_button() -> void:
	$AnimationPlayer.play("RevealNextButton")

func speed_up() -> void:
	$Clock.wait_time = 0.2
	second_incrementor = 4

func _update_labels():
	match(current_second_increment):
		SecondIncrements.ZERO:
			$SecondsLabel.text = "00"
		SecondIncrements.FIFTEEN:
			$SecondsLabel.text = "15"
		SecondIncrements.THIRTY:
			$SecondsLabel.text = "30"
		SecondIncrements.FORTYFIVE:
			$SecondsLabel.text = "45"
	$MinutesLabel.text = "%d" % current_minute

func _increment_minute():
	current_minute += 1
	current_second_increment %= SecondIncrements.size()
	emit_signal("minute_passed", current_minute)

func _on_Clock_timeout():
	current_second_increment += second_incrementor
	if current_second_increment >= SecondIncrements.size():
		_increment_minute()
	_update_labels()
	yield(get_tree().create_timer(0.01), "timeout")
	$Clock.start()

func _on_NextButton_button_down():
	speed_up()

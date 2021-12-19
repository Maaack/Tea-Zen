tool
extends Control

signal button_pressed(button_text)

export(String) var task_name : String = 'Task Name' setget set_task_name
export(Array, String) var task_options : Array = [] setget set_task_options
export(float) var button_min_size : float = 0.0 setget set_button_min_size

func _clear_buttons() -> void:
	for child in $ButtonContainer.get_children():
		child.queue_free()

func set_task_name(value : String) -> void:
	task_name = value
	$TaskLabel.text = task_name

func set_task_options(values : Array) -> void:
	task_options = values
	if not is_inside_tree():
		return
	_clear_buttons()
	for task_name in task_options:
		var new_button = Button.new()
		$ButtonContainer.add_child(new_button)
		new_button.text = task_name
		new_button.rect_min_size.x = button_min_size
		new_button.connect("pressed", self, "_on_button_pressed", [task_name])

func set_button_min_size(value : float) -> void:
	button_min_size = value
	if button_min_size == 0.0:
		return
	if not is_inside_tree():
		return
	for child in $ButtonContainer.get_children():
		child.rect_size.x = button_min_size

func _ready() -> void:
	set_task_options(task_options)

func _on_button_pressed(button_text : String) -> void:
	emit_signal("button_pressed", button_text)

func start_job(job_quantity : String, job_time : float) -> void:
	$ButtonContainer.hide()
	$TaskQuantity.text = job_quantity
	$TaskQuantity.show()
	$TaskClock.wait_time = job_time
	$TaskClock.show()
	$TaskClock.start()

func end_job() -> void:
	$ButtonContainer.show()
	$TaskQuantity.hide()
	$TaskClock.hide()

func _on_TaskClock_timeout():
	end_job()

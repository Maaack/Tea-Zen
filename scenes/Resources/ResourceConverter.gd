extends Node

export(Resource) var input_quantity : Resource
export(Resource) var output_quantity : Resource

var running : bool = false
var job_amount : float = 0.0
var source_quantity : QuantityData

func start_job(job_time: float, attempt_amount : float, source_container : ContainerData, destination_container : ContainerData) -> void:
	if running:
		return
	source_quantity = source_container.find_content(input_quantity.name)
	if source_quantity == null:
		return
	job_amount = min(attempt_amount, source_quantity.quantity)
	if job_amount == 0:
		return
	source_quantity = source_quantity.duplicate()
	source_quantity.quantity = job_amount
	var destination_quantity : QuantityData = output_quantity.duplicate()
	destination_quantity.quantity = job_amount
	source_container.remove_content(source_quantity)
	running = true
	yield(get_tree().create_timer(job_time), "timeout")
	destination_container.add_content(destination_quantity)
	running = false
	job_amount = 0.0

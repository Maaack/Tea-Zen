extends Control

const COLD_WATER_KEY = "Cold Water"
const HOT_WATER_KEY = "Hot Water"
const BLACK_TEA_KEY = "Black Tea"
const RAW_LEAVES_KEY = "Raw Leaves"
const BLACK_TEA_LEAVES_KEY = "Black Tea Leaves"

func _ready():
	$WrittenLogContainer.add_text("I've reached the oasis!")
	$WrittenLogContainer.add_text("It's time for tea!")

func _new_job(job_time: float, job_amount : float, job_controller : Node, converter_node: Node, source_container : ContainerData, destination_container : ContainerData) -> void:
	if converter_node.running:
		return
	converter_node.start_job(job_time, job_amount, source_container, destination_container)
	if converter_node.running:
		job_controller.start_job("%.2f %s" % [converter_node.source_quantity.quantity, converter_node.source_quantity.measure], job_time)

func _new_recipe_job(job_time: float, job_controller : Node, recipe_node: Node, source_container : ContainerData, destination_container : ContainerData) -> void:
	if recipe_node.running:
		return
	recipe_node.start_recipe_job(job_time, source_container, destination_container)
	if recipe_node.running:
		job_controller.start_job("1 L", job_time)

func _on_WaterCollectControl_button_pressed(button_text):
	_new_job(10.0/4, 5.0, $WaterCollectControl, $WaterBucket, $Well.container, $Inventory.container)

func _on_LeavesCollectControl2_button_pressed(button_text):
	_new_job(5.0/4, .25, $LeavesCollectControl, $TeaLeafBag, $TeaPlantsNear.container, $Inventory.container)

func _on_WaterBoilControl_button_pressed(button_text):
	_new_job(5.0/4, 1.0, $WaterBoilControl, $WaterKettle, $Inventory.container, $Inventory.container)

func _on_LeavesDriedControl_button_pressed(button_text):
	_new_job(20.0/4, 10.0, $LeavesDriedControl, $TeaDryerBed, $Inventory.container, $Inventory.container)

func _on_TeaSteepControl_button_pressed(button_text):
	_new_recipe_job(5.0/4, $TeaSteepControl, $Teapot, $Inventory.container, $Inventory.container)

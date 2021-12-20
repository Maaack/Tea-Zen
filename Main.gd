extends Control

export(float) var well_refill_rate : float = 0.0002
export(float) var well_water_level : float = 20.0
export(float) var area_leaves_level : float = 10.0

enum Items{
	NO_ITEM,
	COLD_WATER,
	HOT_WATER,
	RAW_LEAVES,
	DRIED_LEAVES,
	RAW_FLOWERS,
	DRIED_FLOWERS,
	HERBS,
	SPICES,
	BLACK_TEA,
	HERBAL_TEA,
	GREEN_TEA,
	RED_TEA,
	}
var sources : Dictionary = {}
var inventory : Dictionary = {}
var water_collected_counter : int = 0
var water_boiled_counter : int = 0
var tea_steeped_counter : int = 0

func get_water_collected() -> float:
	return inventory[Items.COLD_WATER]

func get_water_boiled() -> float:
	return inventory[Items.HOT_WATER]

func get_tea_steeped() -> float:
	return inventory[Items.BLACK_TEA]

func _ready():
	for item_key in Items.size():
		inventory[item_key] = 0.0
	sources[Items.COLD_WATER] = well_water_level
	sources[Items.RAW_LEAVES] = area_leaves_level
	$WrittenLogContainer.add_text("I've reached the well!")
	$WrittenLogContainer.add_text("Time for some tea!")

func _physics_process(delta):
	sources[Items.COLD_WATER] += well_refill_rate
	$WellWaterReadout.stock_quantity = sources[Items.COLD_WATER]
	$WaterCollectedReadout.stock_quantity = get_water_collected()
	$WaterBoiledReadout.stock_quantity = get_water_boiled()
	$LeavesCollectedReadout.stock_quantity = inventory[Items.RAW_LEAVES]
	$LeavesDriedReadout.stock_quantity = inventory[Items.DRIED_LEAVES]
	$TeaSteepedReadout.stock_quantity = get_tea_steeped()

func _disable_buttons(buttons_list : Array, disabled : bool = true) -> void:
	for button in buttons_list:
		button.disabled = disabled

func _new_job(source_array : Dictionary , destination_array : Dictionary, source_item : int, destination_item : int, amount: float, job_time: float, clock : Node, buttons_container : Node, level_label : Label, level_measure : String) -> void:
	var final_amount = min(amount, source_array[source_item])
	if final_amount == 0:
		return
	if not clock.is_stopped():
		return
	source_array[source_item] -= final_amount
	clock.wait_time = job_time
	clock.start()
	buttons_container.hide()
	level_label.show()
	level_label.text = "%.1f %s" % [final_amount, level_measure]
	yield(clock, "timeout")
	destination_array[destination_item] += final_amount
	level_label.hide()
	buttons_container.show()

func _new_job_2(job_time: float, job_amount : float, job_measure : String, job_controller : Node, source_array : Dictionary , destination_array : Dictionary, source_item : int, destination_item : int) -> void:
	var final_amount = min(job_amount, source_array[source_item])
	if final_amount == 0:
		return
	source_array[source_item] -= final_amount
	job_controller.start_job("%.1f %s" % [final_amount, job_measure], job_time)
	yield(get_tree().create_timer(job_time), "timeout")
	destination_array[destination_item] += final_amount

func _new_collect_water_job(amount: float, job_time: float) -> void:
	_new_job(sources, inventory, Items.COLD_WATER, Items.COLD_WATER, amount, job_time, $CollectClock, $CollectButtonContainer, $CollectingLevel, "L")

func _new_collect_leaves_job(amount: float, job_time: float) -> void:
	_new_job(sources, inventory, Items.RAW_LEAVES, Items.RAW_LEAVES, amount, job_time, $CollectLeavesClock, $CollectLeavesButtonContainer, $CollectingLeavesLevel, "Kg")

func _new_boil_job(amount: float, job_time: float) -> void:
	_new_job(inventory, inventory, Items.COLD_WATER, Items.HOT_WATER, amount, job_time, $BoilClock, $BoilButtonContainer, $BoilingLevel, "L")

func _new_dry_leaves_job(amount: float, job_time: float) -> void:
	_new_job(inventory, inventory, Items.RAW_LEAVES, Items.DRIED_LEAVES, amount, job_time, $DryClock, $DryButton, $DryingLevel, "Kg")

func _on_SteepButton_pressed():
	var tea_steeped_now = min(1.0, get_water_boiled())
	if tea_steeped_now == 0.0:
		return
	inventory[Items.HOT_WATER] -= tea_steeped_now
	inventory[Items.DRIED_LEAVES] -= 0.2
	$SteepButton.disabled = true
	$SteepClock.start()
	yield($SteepClock, "timeout")
	inventory[Items.BLACK_TEA] += tea_steeped_now
	tea_steeped_counter += 1
	$SteepButton.disabled = false

func _on_DryButton_pressed():
	_new_dry_leaves_job(10.0, 20)

func _on_WaterCollectControl_button_pressed(button_text):
	_new_job_2(10.0, 5.0, "L", $WaterCollectControl, sources, inventory, Items.COLD_WATER, Items.COLD_WATER)

func _on_LeavesCollectControl2_button_pressed(button_text):
	_new_job_2(5.0, .25, "Kg", $LeavesCollectControl, sources, inventory, Items.RAW_LEAVES, Items.RAW_LEAVES)

func _on_WaterBoilControl_button_pressed(button_text):
	_new_job_2(5.0, 1.0, "L", $WaterBoilControl, inventory, inventory, Items.COLD_WATER, Items.HOT_WATER)

func _on_LeavesDriedControl_button_pressed(button_text):
	_new_job_2(20.0, 10.0, "Kg", $LeavesDriedControl, inventory, inventory, Items.RAW_LEAVES, Items.DRIED_LEAVES)

extends Control

export(float) var well_refill_rate : float = 0.001
export(float) var well_water_level : float = 20.0
export(float) var area_leaves_level : float = 10.0

enum Items{
	NO_ITEM,
	COLD_WATER,
	HOT_WATER,
	LEAVES,
	TWIGS,
	GRASS,
	TEA_LEAVES,
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
	sources[Items.LEAVES] = area_leaves_level
	$WrittenLogContainer.add_text("I've reached the well!")
	$WrittenLogContainer.add_text("Time for some tea!")

func _physics_process(delta):
	sources[Items.COLD_WATER] += well_refill_rate
	$WellWaterLevel.text = "%.1f L" % sources[Items.COLD_WATER]
	$WaterCollected.text = "%.1f L" % get_water_collected()
	$WaterBoiled.text = "%.1f L" % get_water_boiled()
	$TeaSteeped.text = "%.1f L" % get_tea_steeped()

func _disable_buttons(buttons_list : Array, disabled : bool = true) -> void:
	for button in buttons_list:
		button.disabled = disabled

func _new_job(source_array : Dictionary , destination_array : Dictionary, source : int, destination : int, amount: float, job_time: float, clock : Node, buttons_container : Node, level_label : Label, level_measure : String) -> void:
	var final_amount = min(amount, sources[source])
	if final_amount == 0:
		return
	if not clock.is_stopped():
		return
	source_array[source] -= final_amount
	clock.wait_time = job_time
	clock.start()
	buttons_container.hide()
	level_label.show()
	level_label.text = "%.1f %s" % [final_amount, level_measure]
	yield(clock, "timeout")
	destination_array[destination] += final_amount
	level_label.hide()
	buttons_container.show()

func _new_collect_water_job(amount: float, job_time: float) -> void:
	_new_job(sources, inventory, Items.COLD_WATER, Items.COLD_WATER, amount, job_time, $CollectClock, $CollectButtonContainer, $CollectingLevel, "L")

func _new_collect_leaves_job(amount: float, job_time: float) -> void:
	_new_job(sources, inventory, Items.COLD_WATER, Items.COLD_WATER, amount, job_time, $CollectLeavesClock, $CollectLeavesButtonContainer, $CollectingLeavesLevel, "Kg")

func _new_boil_job(amount: float, job_time: float) -> void:
	_new_job(inventory, inventory, Items.COLD_WATER, Items.HOT_WATER, amount, job_time, $BoilClock, $BoilButtonContainer, $BoilingLevel, "L")

func _on_SteepButton_pressed():
	var tea_steeped_now = min(1.0, get_water_boiled())
	if tea_steeped_now == 0.0:
		return
	inventory[Items.HOT_WATER] -= tea_steeped_now
	$SteepButton.disabled = true
	$SteepClock.start()
	yield($SteepClock, "timeout")
	inventory[Items.BLACK_TEA] += tea_steeped_now
	tea_steeped_counter += 1
	$SteepButton.disabled = false

func _on_Collect1L_pressed():
	_new_collect_water_job(1.0, 10.0)

func _on_Collect10L_pressed():
	_new_collect_water_job(5.0, 42.0)

func _on_Boil1L_pressed():
	_new_boil_job(1.0, 5.0)

func _on_Boil5L_pressed():
	_new_boil_job(5.0, 21.0)

func _on_CollectLeavesNear_pressed():
	_new_collect_leaves_job(0.5, 5.0)

func _on_CollectLeavesFar_pressed():
	_new_collect_leaves_job(1.0, 50.0)

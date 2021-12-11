extends Control

export(float) var well_refill_rate : float = 0.001
export(float) var well_water_level : float = 20.0

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
var inventory : Dictionary = {}
var water_collected_counter : int = 0
var water_boiled_counter : int = 0
var tea_steeped_counter : int = 0

onready var _collect_buttons : Array = [
	$Collect100L,
	$Collect10L,
	$Collect1L
]
onready var _boil_buttons : Array = [
	$Boil10L,
	$Boil1L
]

func get_water_collectable() -> float:
	return well_water_level

func get_water_collected() -> float:
	return inventory[Items.COLD_WATER]

func get_water_boiled() -> float:
	return inventory[Items.HOT_WATER]

func get_tea_steeped() -> float:
	return inventory[Items.BLACK_TEA]

func _ready():
	for item_key in Items.size():
		inventory[item_key] = 0.0
	$WrittenLogContainer.add_text("I've reached the well!")
	$WrittenLogContainer.add_text("Time for some tea!")

func _physics_process(delta):
	well_water_level += well_refill_rate
	$WellWaterLevel.text = "%.1f L" % well_water_level
	$WaterCollected.text = "%.1f L" % get_water_collected()
	$WaterBoiled.text = "%.1f L" % get_water_boiled()
	$TeaSteeped.text = "%.1f L" % get_tea_steeped()

func _disable_buttons(buttons_list : Array, disabled : bool = true) -> void:
	for button in buttons_list:
		button.disabled = disabled

func _new_collect_job(amount: float, job_time: float) -> void:
	var final_amount = min(amount, get_water_collectable())
	if final_amount == 0:
		return
	if not $CollectClock.is_stopped():
		return
	well_water_level -= final_amount
	_disable_buttons(_collect_buttons)
	$CollectClock.wait_time = job_time
	$CollectClock.start()
	yield($CollectClock, "timeout")
	inventory[Items.COLD_WATER] += final_amount
	water_collected_counter += 1
	_disable_buttons(_collect_buttons, false)
	
func _new_boil_job(amount: float, job_time: float) -> void:
	var final_amount = min(amount, get_water_collected())
	if final_amount == 0:
		return
	if not $BoilClock.is_stopped():
		return
	inventory[Items.COLD_WATER] -= final_amount
	_disable_buttons(_boil_buttons)
	$BoilClock.wait_time = job_time
	$BoilClock.start()
	yield($BoilClock, "timeout")
	inventory[Items.HOT_WATER] += final_amount
	water_boiled_counter += 1
	_disable_buttons(_boil_buttons, false)

func _on_BoilButton_pressed():
	var water_boiled_now = min(1.0, get_water_collected())
	if water_boiled_now == 0.0:
		return
	inventory[Items.COLD_WATER] -= water_boiled_now
	$BoilButton.disabled = true
	$BoilClock.start()
	yield($BoilClock, "timeout")
	inventory[Items.HOT_WATER] += water_boiled_now
	water_boiled_counter += 1
	$BoilButton.disabled = false

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
	_new_collect_job(1.0, 10.0)

func _on_Collect10L_pressed():
	_new_collect_job(5.0, 42.0)

func _on_Boil1L_pressed():
	_new_boil_job(1.0, 5.0)

func _on_Boil10L_pressed():
	_new_boil_job(5.0, 21.0)


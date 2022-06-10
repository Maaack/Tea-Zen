extends Control

signal return_button_pressed

const MASTER_AUDIO_BUS = 'Master'
const VOICE_AUDIO_BUS = 'Host'
const MUSIC_AUDIO_BUS = 'Music'
const MUTE_SETTING = 'Mute'
const AUDIO_SECTION = 'AudioSettings'

onready var master_slider = $MasterControl/MasterHSlider
onready var sfx_slider = $SFXControl/SFXHSlider
onready var music_slider = $MusicControl/MusicHSlider
onready var mute_button = $MuteControl/MuteButton

func _get_bus_volume_2_linear(bus_name : String) -> float:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	var volume_db : float = AudioServer.get_bus_volume_db(bus_index)
	return db2linear(volume_db)

func _set_bus_linear_2_volume(bus_name : String, linear : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	var volume_db : float = linear2db(linear)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	Config.set_config(AUDIO_SECTION, bus_name, linear)

func _is_muted() -> bool:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	return AudioServer.is_bus_mute(bus_index)

func _set_mute(mute_flag : bool) -> void:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	AudioServer.set_bus_mute(bus_index, mute_flag)
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, mute_flag)

func _update_ui():
	master_slider.value = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	sfx_slider.value = _get_bus_volume_2_linear(VOICE_AUDIO_BUS)
	music_slider.value = _get_bus_volume_2_linear(MUSIC_AUDIO_BUS)
	mute_button.pressed = _is_muted()

func _set_init_config():
	Config.set_config(AUDIO_SECTION, MASTER_AUDIO_BUS, _get_bus_volume_2_linear(MASTER_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, VOICE_AUDIO_BUS, _get_bus_volume_2_linear(VOICE_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, MUSIC_AUDIO_BUS, _get_bus_volume_2_linear(MUSIC_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, _is_muted())

func _sync_with_config():
	if not Config.has_section(AUDIO_SECTION):
		_set_init_config()
	var master_audio_value : float = Config.get_config(AUDIO_SECTION, MASTER_AUDIO_BUS)
	var voice_audio_value : float = Config.get_config(AUDIO_SECTION, VOICE_AUDIO_BUS)
	var music_audio_value : float = Config.get_config(AUDIO_SECTION, MUSIC_AUDIO_BUS)
	var mute_audio_flag  : bool = Config.get_config(AUDIO_SECTION, MUTE_SETTING, _is_muted())
	_set_bus_linear_2_volume(MASTER_AUDIO_BUS, master_audio_value)
	_set_bus_linear_2_volume(VOICE_AUDIO_BUS, voice_audio_value)
	_set_bus_linear_2_volume(MUSIC_AUDIO_BUS, music_audio_value)
	_set_mute(mute_audio_flag)
	_update_ui()

func _ready():
	_sync_with_config()

func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_MasterHSlider_value_changed(value):
	_set_bus_linear_2_volume(MASTER_AUDIO_BUS, value)

func _on_SFXHSlider_value_changed(value):
	_set_bus_linear_2_volume(VOICE_AUDIO_BUS, value)

func _on_MusicHSlider_value_changed(value):
	_set_bus_linear_2_volume(MUSIC_AUDIO_BUS, value)

func _on_MuteButton_toggled(button_pressed):
	_set_mute(button_pressed)

func _unhandled_key_input(event):
	if event.is_action_released('ui_mute'):
		mute_button.pressed = !(mute_button.pressed)

func _on_ResetButton_pressed():
	$ResetGameControl/ResetButton.hide()
	$ResetGameControl/ResetCancelButton.show()
	$ResetGameControl/DividerLabel.show()
	$ResetGameControl/ResetConfirmButton.show()

func _on_ResetCancelButton_pressed():
	$ResetGameControl/ResetCancelButton.hide()
	$ResetGameControl/DividerLabel.hide()
	$ResetGameControl/ResetConfirmButton.hide()
	$ResetGameControl/ResetButton.show()

func _on_ResetConfirmButton_pressed():
	PersistentData.reset_memory()
	$ResetGameControl/ResetCancelButton.hide()
	$ResetGameControl/DividerLabel.hide()
	$ResetGameControl/ResetConfirmButton.hide()
	$ResetGameControl/ResetConfirmationLabel.show()

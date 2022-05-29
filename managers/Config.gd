extends Node

const CONFIG_FILE_LOCATION := "user://config.cfg"

var config_file : ConfigFile

func _init():
	load_config_file()

func load_config_file() -> void:
	if config_file != null:
		return
	config_file = ConfigFile.new()
	var load_error : int = config_file.load(CONFIG_FILE_LOCATION)
	if load_error: 
		var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
		if save_error:
			print("save config file failed with error %d" % save_error)

func set_config(section: String, key: String, value) -> void:
	load_config_file()
	config_file.set_value(section, key, value)
	var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
	if save_error:
		print("save config file failed with error %d" % save_error)

func get_config(section: String, key: String, default = null):
	load_config_file()
	return config_file.get_value(section, key, default)

func has_section(section: String):
	load_config_file()
	return config_file.has_section(section)

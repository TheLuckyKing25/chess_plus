extends Node

var config:ConfigFile = ConfigFile.new()
const SETTINGS_FILE_PATH: String = "user://settings.ini"


func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("KeyBindings", "Interact", "mouse_1")

		config.set_value("Video", "fullscreen", true)

		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		config.set_value("audio", "ui_volume", 1.0)
		config.set_value("audio", "game_volume", 1.0)

		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


func save_video_settings(key: String, value: Variant) -> void:
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)


func load_video_settings() -> Dictionary[String,Variant]:
	var video_settings: Dictionary[String,Variant] = {}
	for key:String in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


func save_audio_settings(key: String, value: Variant) -> void:
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)


func load_audio_settings() -> Dictionary[String,Variant]:
	var audio_settings:Dictionary[String,Variant] = {}
	for key:String in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

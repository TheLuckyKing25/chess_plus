extends UIBaseClass

@export var fullscreen_checkbox: CheckBox

@export var master_slider: Slider
@export var music_slider: Slider
@export var ui_slider: Slider
@export var game_slider: Slider


const SETTINGS_CONFIG_FILE_PATH: String = "user://settings.ini"


const DEFAULT_CONFIG: Dictionary = {
	"KeyBindings": {
		"Interact": "mouse_1"
	},
	"video": {
		"fullscreen": true
	},
	"audio": {
		"master_volume": 100.0,
		"music_volume": 100.0,
		"ui_volume": 100.0,
		"game_volume": 100.0
	}
}


var config_file: SettingsConfigHandler


func _connect_to_back_button(function:Callable):
	%Back.pressed.connect(function)


func _ready():
	config_file = SettingsConfigHandler.new(SETTINGS_CONFIG_FILE_PATH, DEFAULT_CONFIG.duplicate(true))
	var video_settings = config_file.load_video_settings()
	fullscreen_checkbox.button_pressed = video_settings.fullscreen

	var audio_settings = config_file.load_audio_settings()
	master_slider.set_volume(audio_settings.get(master_slider.config_setting_name))
	music_slider.set_volume(audio_settings.get(music_slider.config_setting_name))
	ui_slider.set_volume(audio_settings.get(ui_slider.config_setting_name))
	game_slider.set_volume(audio_settings.get(game_slider.config_setting_name))


#region Display Settings
#Fullscreen
func _on_check_box_toggled(toggled_on:bool) -> void:
	var window_mode: DisplayServer.WindowMode = (
			DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on
			else DisplayServer.WINDOW_MODE_WINDOWED
		)
	DisplayServer.window_set_mode(window_mode)


#Resolution
func _on_option_button_item_selected(index: int) -> void:
	pass # Replace with function body.

#endregion
#Controls

#Buttons
#Apply
func _on_apply_pressed() -> void:
	%Apply.disabled = true
	config_file.save_video_settings("fullscreen", fullscreen_checkbox.is_pressed())

	config_file.save_audio_settings("master_volume", master_slider.value)
	config_file.save_audio_settings("music_volume", music_slider.value)
	config_file.save_audio_settings("ui_volume", ui_slider.value)
	config_file.save_audio_settings("game_volume", game_slider.value)


#Cancel
func _on_cancel_pressed() -> void:
	var action_event = InputEventAction.new()
	action_event.action = "ui_cancel"
	action_event.pressed = true
	Input.parse_input_event(action_event)

#Default
func _on_default_pressed() -> void:
	fullscreen_checkbox.button_pressed = false
	master_slider.value = 100
	music_slider.value = 100
	ui_slider.value = 100
	game_slider.value =  100


func _on_setting_changed(value_changed: bool) -> void:
	%Apply.disabled = !value_changed


class SettingsConfigHandler extends ConfigFileHandler:
	var file_path: String


	func _init(config_file_path: String, default_config:Dictionary):
		file_path = config_file_path
		if !FileAccess.file_exists(file_path):
			set_config_with_dictionary(default_config)
			config.save(file_path)
		else:
			config.load(file_path)


	func save_video_settings(key: String, value: Variant) -> void:
		config.set_value("video", key, value)
		config.save(file_path)


	func load_video_settings() -> Dictionary[String,Variant]:
		var video_settings: Dictionary[String,Variant] = {}
		for key:String in config.get_section_keys("video"):
			video_settings[key] = config.get_value("video", key)
		return video_settings


	func save_audio_settings(key: String, value: Variant) -> void:
		config.set_value("audio", key, value)
		config.save(file_path)


	func load_audio_settings() -> Dictionary[String,Variant]:
		var audio_settings:Dictionary[String,Variant] = {}
		for key:String in config.get_section_keys("audio"):
			audio_settings[key] = config.get_value("audio", key)
		return audio_settings

extends Control


@onready var fullscreen_checkbox = $Panel/Panel/VBoxContainer/TabContainer/Graphics/VBoxContainer/HBoxContainer2/Fullscreen


@onready var master_slider = $Panel/Panel/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer/Master
@onready var music_slider = $Panel/Panel/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer2/Music
@onready var ui_slider = $Panel/Panel/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer3/UI
@onready var game_slider = $Panel/Panel/VBoxContainer/TabContainer/Audio/VBoxContainer/HBoxContainer4/Game


func _ready():
	hide()
	
	var video_settings = ConfigFileHandler.load_video_settings()
	fullscreen_checkbox.button_pressed = video_settings.fullscreen
	
	var audio_settings = ConfigFileHandler.load_audio_settings()
	master_slider.value = audio_settings.master_volume
	music_slider.value = audio_settings.music_volume
	ui_slider.value = audio_settings.ui_volume
	game_slider.value = audio_settings.game_volume

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()

#Graphics
#Fullscreen
func _on_check_box_toggled(toggled_on):
	ConfigFileHandler.save_video_settings("fullscreen", toggled_on)
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#Resolution
func _on_option_button_item_selected(index: int) -> void:
	pass # Replace with function body.

#Audio
#Master Volume
func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	ConfigFileHandler.save_audio_settings("master_volume", value)
	
#Music Volume
func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	ConfigFileHandler.save_audio_settings("music_volume", value)
	
#UI Volume
func _on_ui_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(value))
	ConfigFileHandler.save_audio_settings("ui_volume", value)

#Game Sounds
func _on_game_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Game"), linear_to_db(value))
	ConfigFileHandler.save_audio_settings("game_volume", value)


#Controls


#Buttons
#Apply
func _on_apply_pressed() -> void:
	var action_event = InputEventAction.new()
	action_event.action = "ui_cancel"
	action_event.pressed = true  
	Input.parse_input_event(action_event)

#Cancel
func _on_cancel_pressed() -> void:
	pass # Replace with function body.

#Default
func _on_default_pressed() -> void:
	fullscreen_checkbox.button_pressed = false
	master_slider.value = 100
	music_slider.value = 100
	ui_slider.value = 100
	game_slider.value =  100

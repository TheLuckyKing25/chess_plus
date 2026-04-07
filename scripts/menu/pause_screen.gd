extends Control


const _SETTINGS_MENU: PackedScene = preload("uid://0fccgu7f77gg")


var _settings_menu: Node


func _connect_to_resume_button(function: Callable):
	$PauseMenu/BoxContainer/VBoxContainer/Resume.pressed.connect(function)


func _connect_to_leave_button(function: Callable):
	$PauseMenu/BoxContainer/VBoxContainer/Leave.pressed.connect(function)


func _disconnect_from_resume_button(function: Callable):
	$PauseMenu/BoxContainer/VBoxContainer/Resume.pressed.disconnect(function)


func _disconnect_from_leave_button(function: Callable):
	$PauseMenu/BoxContainer/VBoxContainer/Leave.pressed.disconnect(function)


func _on_options_pressed():
	_settings_menu = _SETTINGS_MENU.instantiate()
	$PauseMenu.hide()
	add_child(_settings_menu)
	_settings_menu._connect_to_back_button(Callable(self,"_on_settings_back_button_pressed"))

func _on_settings_back_button_pressed():
	_settings_menu.hide()
	$PauseMenu.show()
	_settings_menu.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _settings_menu:
			_on_settings_back_button_pressed()
		else:
			get_tree().paused = false

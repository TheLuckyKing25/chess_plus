extends Control

signal resume_button_pressed()
signal settings_button_pressed()
signal leave_button_pressed()


func _on_resume_pressed():
	resume_button_pressed.emit()
	$ScreenController.position = Vector2(0,0)
	

func _on_options_pressed():
	settings_button_pressed.emit()
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/SettingsScreen.position


func _on_exit_pressed():
	leave_button_pressed.emit()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and get_tree().paused:
		_on_resume_pressed()

func _on_settings_back_button_pressed() -> void:
	$ScreenController.position = Vector2(0,0)

extends Control

func _on_ready():
	if GameNode3D.debug_setting.DEBUG_SKIP_TITLE:
		get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		$ScreenController.position = Vector2(0,0)


func _on_start_pressed():
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/MatchSelectionScreen.position

func _on_settings_pressed():
	$ScreenController/SettingsScreen/Settings.show()
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/SettingsScreen.position

func _on_exit_pressed():
	get_tree().quit()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

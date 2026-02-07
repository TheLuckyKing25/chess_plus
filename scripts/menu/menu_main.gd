extends Control

func _on_ready():
	if GameNode3D.debug_setting.DEBUG_SKIP_TITLE:
		get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		$ScreenControl.position = Vector2(0,0)


func _on_start_pressed():
	$ScreenControl.position = Vector2(-1,-1) * $ScreenControl/Start.position

func _on_settings_pressed():
	$ScreenControl/Options/Settings.show()
	$ScreenControl.position = Vector2(-1,-1) * $ScreenControl/Options.position

func _on_exit_pressed():
	get_tree().quit()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

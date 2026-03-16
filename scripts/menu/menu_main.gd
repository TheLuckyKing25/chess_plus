extends Control

func _on_ready():
	if GameNode3D.debug_setting.DEBUG_SKIP_TITLE:
		get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")
	NetworkManager.connected_to_game.connect(_on_connected_to_game)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		$ScreenController.position = Vector2(0,0)


func _on_settings_pressed():
	$ScreenController/SettingsScreen/Settings.show()
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/SettingsScreen.position

func _on_exit_pressed():
	get_tree().quit()

func _on_new_match_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _on_host_pressed() -> void:
	NetworkManager.host_game()

func _on_join_pressed() -> void:
	NetworkManager.join_game("127.0.0.1")

func _on_connected_to_game() -> void:
	print("Both players connected")
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

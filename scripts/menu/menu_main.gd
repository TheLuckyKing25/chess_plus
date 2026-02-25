extends Control

func _on_ready():
	if GameNode3D.debug_setting.DEBUG_SKIP_TITLE:
		get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")
	NetworkManager.connected_to_game.connect(_on_connected_to_game)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and %Main.visible == false:
		%Start.hide()
		%Main.show()

func _on_start_pressed():
	%Main.hide()
	%Start.show()

func _on_settings_pressed():
	%Options/Settings.show()
	%Main.hide()

func _on_exit_pressed():
	get_tree().quit()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _on_host_pressed() -> void:
	NetworkManager.host_game()

func _on_join_pressed() -> void:
	NetworkManager.join_game("127.0.0.1")

func _on_connected_to_game() -> void:
	print("Both players connected")
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

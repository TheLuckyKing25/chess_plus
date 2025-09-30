extends Control

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and $Main.visible == false:
		$Main.show()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/gameEnvironment.tscn")

func _on_settings_pressed():
	$Options/Settings.show()
	$Main.hide()

func _on_exit_pressed():
	get_tree().quit()

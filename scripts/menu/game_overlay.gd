extends Control


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$ScreenController.position = Vector2(-1,-1) * $ScreenController/PauseMenu.position


func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	$ScreenController.position = Vector2(0,0)

# When Escape pressed: pause game or resume game, depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		_on_pause_button_pressed()
			

func _on_pause_menu_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")
	#get_tree().quit()


func _on_debug_toggled(toggled_on: bool) -> void:
	$ScreenController/DebugMenu.visible = toggled_on

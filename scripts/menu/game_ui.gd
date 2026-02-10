extends Control


func _ready() -> void:
	$PauseMenu.hide()
	$PauseButton.show()
	

# When Escape pressed: pause game or resume game, depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		_on_pause_button_pressed()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused:
		_on_pause_menu_resume_button_pressed()


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$PauseMenu.show()
	$PauseButton.hide()


func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.hide()
	$PauseButton.show()


func _on_pause_menu_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")
	#get_tree().quit()

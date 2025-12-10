extends Control


#When Game starts menu is hidden
func _ready():
	hide()
	$"Pause Button".show()
	$Pause.hide()


func resume():
	get_tree().paused = false
	$"Pause Button".show()
	$Pause.hide()


func pause():
	get_tree().paused = true
	$"Pause Button".hide()
	$Pause.show()


#When Escape pressed pause game, or resume game depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		pause()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and $Pause.visible == true:
		resume()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and visible == false:
		pause()


func _on_resume_pressed():
	resume()
	

func _on_options_pressed():
	$Settings/Settings.show()
	$Pause.hide()


func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")
	#get_tree().quit()


func _on_pause_button_gui_input() -> void:
	pause()

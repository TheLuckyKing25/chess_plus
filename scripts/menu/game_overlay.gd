extends Control


func _connent_to_debug_button(function: Callable):
	$MenuButtons/MenuButtons/Debug.toggled.connect(function)

func _connect_to_pause_button(function: Callable):
	$MenuButtons/MenuButtons/PauseButton.pressed.connect(function)

func _connect_to_rulebook_button(function: Callable):
	$MenuButtons/MenuButtons/RuleBookButton.pressed.connect(function)

# When Escape pressed: pause game or resume game, depenent on state.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and !get_tree().paused:
		pass

func _on_pause_menu_leave_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/StartScreen.tscn")
	#get_tree().quit()

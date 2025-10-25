extends Control

func _ready():
	hide()

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()

#Graphics
#Fullscreen
func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#Resolution
func _on_option_button_item_selected(index: int) -> void:
	pass # Replace with function body.

#Audio
#Master Volume
func _on_master_value_changed(value: float) -> void:
	pass # Replace with function body.
	
#Music Volume
func _on_music_value_changed(value: float) -> void:
	pass # Replace with function body.
	
#UI Volume
func _on_ui_value_changed(value: float) -> void:
	pass # Replace with function body.

#Game Sounds
func _on_game_value_changed(value: float) -> void:
	pass # Replace with function body.

#Controls


#Buttons
#Apply
func _on_apply_pressed() -> void:
	pass # Replace with function body.

#Cancel
func _on_cancel_pressed() -> void:
	pass # Replace with function body.

#Default
func _on_default_pressed() -> void:
	pass # Replace with function body.

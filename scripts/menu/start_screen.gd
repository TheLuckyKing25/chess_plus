extends Control

const SETTINGS_MENU = preload("res://scenes/menu/settings_menu.tscn")
const GAME_ENVIRONMENT = preload("res://scenes/game_environment.tscn")

var settings_menu: Node
var game_environment: Node


func _on_ready():
	pass

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_menu:
			remove_child(settings_menu)
			settings_menu.queue_free()
			$MainMenu.show()
		else:
			_on_exit_button_pressed()

#region Main Menu Buttons

func _on_new_match_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_environment.tscn")

func _on_join_match_button_pressed() -> void:
	pass # Replace with function body.


func _on_rulebook_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	settings_menu = SETTINGS_MENU.instantiate()
	add_child(settings_menu)
	$MainMenu.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()

#endregion

extends Control

const SETTINGS_MENU = preload("uid://0fccgu7f77gg")
const JOIN_MENU = preload("uid://cvr8wyhalupas")
const GAME_ENVIRONMENT = preload("uid://h7v0gyqyq0h7")

var settings_menu: Node
var join_menu: Node
var game_environment: Node


func _on_ready():
	pass

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_menu:
			remove_child(settings_menu)
			settings_menu.queue_free()
			$MainMenu.show()
		elif join_menu:
			remove_child(join_menu)
			join_menu.queue_free()
			$MainMenu.show()
		else:
			_on_exit_button_pressed()

#region Main Menu Buttons

func _on_new_match_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://h7v0gyqyq0h7")

func _on_join_match_button_pressed() -> void:
	join_menu = JOIN_MENU.instantiate()
	add_child(join_menu)
	$MainMenu.hide()

func _on_rulebook_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	settings_menu = SETTINGS_MENU.instantiate()
	add_child(settings_menu)
	$MainMenu.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()

#endregion

extends Control

const SETTINGS_MENU = preload("uid://0fccgu7f77gg")
const JOIN_MENU = preload("uid://cvr8wyhalupas")

var settings_menu: Node
var join_menu: Node
var game_environment: Node

func connect_to_scene(
		new_match: Callable,
		join_match: Callable,
		rulebook: Callable,
		settings: Callable,
		exit: Callable
	):
	%NewMatchButton.pressed.connect(new_match)
	%JoinMatchButton.pressed.connect(join_match)
	%RulebookButton.pressed.connect(rulebook)
	%SettingsButton.pressed.connect(settings)
	%ExitButton.pressed.connect(exit)

func disconnect_from_scene(
		new_match: Callable,
		join_match: Callable,
		rulebook: Callable,
		settings: Callable,
		exit: Callable
	):
	%NewMatchButton.pressed.disconnect(new_match)
	%JoinMatchButton.pressed.disconnect(join_match)
	%RulebookButton.pressed.disconnect(rulebook)
	%SettingsButton.pressed.disconnect(settings)
	%ExitButton.pressed.disconnect(exit)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_menu:
			remove_child(settings_menu)
			settings_menu.queue_free()
			$MainMenu.show()

#region Main Menu Buttons
func _on_rulebook_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	settings_menu = SETTINGS_MENU.instantiate()
	add_child(settings_menu)
	$MainMenu.hide()
#endregion

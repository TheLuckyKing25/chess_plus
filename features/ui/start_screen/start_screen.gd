extends UIBaseClass

const SETTINGS_MENU = preload("uid://0fccgu7f77gg")
const JOIN_MENU = preload("uid://cvr8wyhalupas")


@export var new_match_button: SceneTransitionButton
@export var join_match_button: SceneTransitionButton
@export var rulebook_button: SceneTransitionButton
@export var settings_button: SceneTransitionButton
@export var exit_button: SceneTransitionButton


#var settings_menu: Node
#var join_menu: Node
#var game_environment: Node


#func connect_to_scene(
		#new_match: Callable,
		#join_match: Callable,
		#rulebook: Callable,
		#settings: Callable,
		#exit: Callable
	#):
	#%NewMatchButton.pressed.connect(new_match)
	#%JoinMatchButton.pressed.connect(join_match)
	#%RulebookButton.pressed.connect(rulebook)
	#%SettingsButton.pressed.connect(settings)
	#%ExitButton.pressed.connect(exit)
#
#
#func disconnect_from_scene(
		#new_match: Callable,
		#join_match: Callable,
		#rulebook: Callable,
		#settings: Callable,
		#exit: Callable
	#):
	#%NewMatchButton.pressed.disconnect(new_match)
	#%JoinMatchButton.pressed.disconnect(join_match)
	#%RulebookButton.pressed.disconnect(rulebook)
	#%SettingsButton.pressed.disconnect(settings)
	#%ExitButton.pressed.disconnect(exit)


func _ready() -> void:
	new_match_button.pressed.connect(push_scene.emit.bind(new_match_button.transition_to_scene))
	join_match_button.pressed.connect(push_scene.emit.bind(join_match_button.transition_to_scene))
	rulebook_button.pressed.connect(push_scene.emit.bind(rulebook_button.transition_to_scene))
	settings_button.pressed.connect(push_scene.emit.bind(settings_button.transition_to_scene))
	exit_button.pressed.connect(pop_scene.emit.bind())


#func _instantiate_scene(scene: PackedScene, root_node: Node):
	#if scene == null:
		#queue_free()
		#return
#
	#var loaded_scene:Node = scene.instantiate()
	#root_node.add_child(loaded_scene,true)



#func _input(event) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#if settings_menu:
			#remove_child(settings_menu)
			#settings_menu.queue_free()
			#$MainMenu.show()

#region Main Menu Buttons
#func _on_rulebook_button_pressed() -> void:
	#pass # Replace with function body.
#
#
#func _on_settings_button_pressed() -> void:
	#settings_menu = SETTINGS_MENU.instantiate()
	#add_child(settings_menu)
	#$MainMenu.hide()
#endregion

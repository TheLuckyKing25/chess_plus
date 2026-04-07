class_name TileModifierSelectionState
extends UIState

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene._connect_to_back_button(Callable(self,"on_back_pressed"))
	instantiated_scene._connect_to_continue_button(Callable(self,"on_continue_pressed"))
	instantiated_scene._connect_to_host_button(Callable(self,"on_host_pressed"))

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)
	instantiated_scene._disconnect_from_back_button(Callable(self,"on_back_pressed"))
	instantiated_scene._disconnect_from_continue_button(Callable(self,"on_continue_pressed"))
	instantiated_scene._disconnect_from_host_button(Callable(self,"on_host_pressed"))

	ui_root.remove_child(instantiated_scene)

func _input(event:InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_back_pressed():
	transitioned.emit(self, "MatchCustomizationState")


func on_continue_pressed():
	transitioned.emit(self, "GameOverlayState")


func on_host_pressed():
	transitioned.emit(self, "WaitStateTileMod")

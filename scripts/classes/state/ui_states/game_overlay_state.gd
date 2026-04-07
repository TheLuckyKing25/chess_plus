class_name GameOverlayState
extends UIState

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene._connect_to_pause_button(Callable(self,"on_pause_pressed"))

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)
	instantiated_scene._disconnect_from_pause_button(Callable(self,"on_pause_pressed"))

	ui_root.remove_child(instantiated_scene)


func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_pause_pressed()


func on_pause_pressed():
	transitioned.emit(self, "PauseMenuState")

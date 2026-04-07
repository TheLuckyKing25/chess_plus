class_name MatchCustomizationState
extends UIState

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.back_button_pressed.connect(Callable(self,"on_back_pressed"))
	instantiated_scene.start_button_pressed.connect(Callable(self,"on_start_pressed"))
	instantiated_scene.host_button_pressed.connect(Callable(self,"on_host_pressed"))
	instantiated_scene.continue_button_pressed.connect(Callable(self,"on_continue_pressed"))

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)
	instantiated_scene.back_button_pressed.disconnect(Callable(self,"on_back_pressed"))
	instantiated_scene.start_button_pressed.disconnect(Callable(self,"on_start_pressed"))
	instantiated_scene.host_button_pressed.disconnect(Callable(self,"on_host_pressed"))
	instantiated_scene.continue_button_pressed.disconnect(Callable(self,"on_continue_pressed"))

	ui_root.remove_child(instantiated_scene)


func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()


func on_back_pressed():
	transitioned.emit(self, "StartMenuState")

func on_host_pressed():
	transitioned.emit(self, "WaitStateMatchCustom")

func on_start_pressed():
	transitioned.emit(self, "GameOverlayState")


func on_continue_pressed():
	transitioned.emit(self, "TileModifierSelectionState")

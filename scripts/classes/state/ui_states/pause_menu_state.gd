class_name PauseMenuState
extends UIState

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene._connect_to_resume_button(Callable(self,"on_resume_pressed"))
	instantiated_scene._connect_to_leave_button(Callable(self,"on_leave_pressed"))

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)
	instantiated_scene._disconnect_from_resume_button(Callable(self,"on_resume_pressed"))
	instantiated_scene._disconnect_from_leave_button(Callable(self,"on_leave_pressed"))

	ui_root.remove_child(instantiated_scene)


func on_resume_pressed():
	transitioned.emit(self, "GameOverlayState")

func on_leave_pressed():
	transitioned.emit(self, "StartMenuState")

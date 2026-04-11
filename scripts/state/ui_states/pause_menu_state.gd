class_name PauseMenuState
extends UIState

func enter():
	print_rich("[b][color=green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene._connect_to_resume_button(Callable(self,"on_resume_pressed"))
	instantiated_scene._connect_to_leave_button(Callable(self,"on_leave_pressed"))

	add_child(instantiated_scene)


func exit():
	instantiated_scene._disconnect_from_resume_button(Callable(self,"on_resume_pressed"))
	instantiated_scene._disconnect_from_leave_button(Callable(self,"on_leave_pressed"))

	remove_child(instantiated_scene)
	#print_debug("exit ", name)
	print_rich("[b][color=red]Exited[/color]: [/b]",name)

func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_resume_pressed()

func on_resume_pressed():
	transitioned.emit(self, "GameOverlayState")

func on_leave_pressed():
	transitioned.emit(self, "StartMenuState")

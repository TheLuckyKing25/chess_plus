extends UIState


func enter():
	print_rich("[b][color=web_green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	add_child(instantiated_scene)
	instantiated_scene.back_button.pressed.connect(Callable(self,"on_back_pressed"))

func exit():
	instantiated_scene.back_button.pressed.disconnect(Callable(self,"on_back_pressed"))
	remove_child(instantiated_scene)
	#print_debug("exit ", name)
	print_rich("[b][color=brown]Exited[/color]: [/b]",name)


func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_back_pressed():
	transitioned.emit(self, "StartMenuState")

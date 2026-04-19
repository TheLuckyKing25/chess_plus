extends UIState

func enter():
	print_rich("[b][color=web_green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.join_button.pressed.connect(Callable(self,"on_join_pressed"))

	add_child(instantiated_scene)


func exit():

	instantiated_scene.join_button.pressed.disconnect(Callable(self,"on_join_pressed"))

	remove_child(instantiated_scene)
	instantiated_scene.queue_free()
	#print_debug("exit ", name)
	print_rich("[b][color=brown]Exited[/color]: [/b]",name)


func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_join_pressed():
	if instantiated_scene.ip.is_empty() or instantiated_scene.port.length() < 4:
		return

	NetworkManager.connected_to_game.connect(instantiated_scene._on_connected_to_game)
	NetworkManager.join_game(instantiated_scene.ip, instantiated_scene.port)
	transitioned.emit(self, "LoadingState")


func on_back_pressed():
	transitioned.emit(self, "StartMenuState")

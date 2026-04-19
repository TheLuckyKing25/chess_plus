extends UIState

func enter():
	print_rich("[b][color=web_green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.connect_to_scene(
			Callable(self,"on_new_match_pressed"),
			Callable(self,"on_join_match_pressed"),
			Callable(self,"on_rulebook_pressed"),
			Callable(self,"on_settings_pressed"),
			Callable(self,"on_exit_pressed"),
			)

	add_child(instantiated_scene)


func exit():
	instantiated_scene.disconnect_from_scene(
			Callable(self,"on_new_match_pressed"),
			Callable(self,"on_join_match_pressed"),
			Callable(self,"on_rulebook_pressed"),
			Callable(self,"on_settings_pressed"),
			Callable(self,"on_exit_pressed"),
			)

	remove_child(instantiated_scene)
	#print_debug("exit ", name)
	print_rich("[b][color=brown]Exited[/color]: [/b]",name)


func on_new_match_pressed():
	transitioned.emit(self, "MatchCustomizationStateM")


func on_join_match_pressed():
	transitioned.emit(self, "JoinState")


func on_rulebook_pressed():
	transitioned.emit(self,"GuidebookScreenState")

func on_settings_pressed():
	pass

func on_exit_pressed():
	get_tree().quit()

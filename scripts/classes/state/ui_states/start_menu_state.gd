class_name StartMenuState
extends UIState

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.connect_to_scene(
			Callable(self,"on_new_match_pressed"),
			Callable(self,"on_join_match_pressed"),
			Callable(self,"on_rulebook_pressed"),
			Callable(self,"on_settings_pressed"),
			Callable(self,"on_exit_pressed"),
			)

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)
	instantiated_scene.disconnect_from_scene(
			Callable(self,"on_new_match_pressed"),
			Callable(self,"on_join_match_pressed"),
			Callable(self,"on_rulebook_pressed"),
			Callable(self,"on_settings_pressed"),
			Callable(self,"on_exit_pressed"),
			)

	ui_root.remove_child(instantiated_scene)


func on_new_match_pressed():
	transitioned.emit(self, "MatchCustomizationState")


func on_join_match_pressed():
	transitioned.emit(self, "JoinState")


func on_rulebook_pressed():
	pass

func on_settings_pressed():
	pass

func on_exit_pressed():
	get_tree().quit()

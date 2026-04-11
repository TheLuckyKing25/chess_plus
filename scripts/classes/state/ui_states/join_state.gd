class_name JoinState
extends UIState

func enter():
	print_rich("[b][color=green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	#instantiated_scene.connect_to_scene()

	add_child(instantiated_scene)


func exit():

	#instantiated_scene.disconnect_from_scene()

	remove_child(instantiated_scene)
	instantiated_scene.queue_free()
	#print_debug("exit ", name)
	print_rich("[b][color=red]Exited[/color]: [/b]",name)


func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_join_pressed():
	transitioned.emit(self, "LoadingState")


func on_back_pressed():
	transitioned.emit(self, "StartMenuState")

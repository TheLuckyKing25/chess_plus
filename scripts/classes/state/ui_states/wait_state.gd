class_name WaitState
extends UIState

@export var previous_state:State

func enter():
	print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	#instantiated_scene.connect_to_scene()

	ui_root.add_child(instantiated_scene)


func exit():
	print_debug("exit ", name)

	#instantiated_scene.disconnect_from_scene()

	ui_root.remove_child(instantiated_scene)
	instantiated_scene.queue_free()


func _input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_connection():
	transitioned.emit(self, "LoadingState")


func on_back_pressed():
	transitioned.emit(self, previous_state.name)

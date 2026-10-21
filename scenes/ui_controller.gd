class_name UIController
extends Control


@export var starting_scene: PackedScene


func _ready() -> void:
	var loaded_scene: UIBaseClass = starting_scene.instantiate()
	connect_scene_signals(loaded_scene)
	add_child(loaded_scene)


func connect_scene_signals(scene:UIBaseClass):
	scene.pop_scene.connect(_pop_scene)
	scene.push_scene.connect(_push_scene)
	scene.reset_to_first_scene.connect(_clear_scene_stack)


func disconnect_scene_signals(scene:UIBaseClass):
	scene.pop_scene.disconnect(_pop_scene)
	scene.push_scene.disconnect(_push_scene)
	scene.reset_to_first_scene.disconnect(_clear_scene_stack)


func _push_scene(scene: PackedScene):
	var loaded_scene: UIBaseClass = scene.instantiate()
	var prev_scene: UIBaseClass = get_children().back()

	disconnect_scene_signals(prev_scene)
	connect_scene_signals(loaded_scene)

	add_child(loaded_scene)
	prev_scene.hide()


func _pop_scene():
	if get_child_count() == 1:
		get_tree().exit()
	var last_scene: UIBaseClass = get_children().back()
	disconnect_scene_signals(last_scene)
	remove_child(last_scene)
	last_scene.queue_free()

	var prev_scene: UIBaseClass = get_children().back()
	connect_scene_signals(prev_scene)


func _clear_scene_stack():
	pass

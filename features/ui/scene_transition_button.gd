## A button that instantiates a given scene when pressed,
## or calls queue_free on the current scene.
class_name SceneTransitionButton
extends Button

enum ExitType {
	## Calls queue_free() on the current scene,
	## revealing the scene underneath, if one exists.
	EXIT_CURRENT_SCENE,
	## Calls queue_free() on all the menu scenes of the current menu_layer
	CLEAR_SCENE_STACK
}

## Leave empty to exit current scene.
@export var transition_to_scene: PackedScene:
	set(scene):
		transition_to_scene = scene
		notify_property_list_changed()


@export var exit_type: ExitType


func _validate_property(property: Dictionary) -> void:
	if property.name in ["exit_type"]:
		if is_instance_valid(transition_to_scene):
			property.usage = PROPERTY_USAGE_NO_EDITOR

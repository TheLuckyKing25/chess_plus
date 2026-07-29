@abstract class_name ObjectStateComponent
extends Node

signal state_changed(new_state: StringName)

@export var mesh_component: MeshComponent

const STATE_NONE: StringName = &"State_None"
const STATE_SELECTED: StringName = &"State_Selected"
const STATE_THREATENED: StringName = &"State_Threatened"
const STATE_CHECKED: StringName = &"State_Checked"
const STATE_CASTLING: StringName = &"State_Castling"

# unused by tiles
const STATE_CHECKING: StringName = &"State_Checking"

# unused by piece
const STATE_MOVEMENT: StringName = &"State_Movement"
const STATE_CHECKED_MOVEMENT: StringName = &"State_Checked_Movement"


var _state_function_lookup: Dictionary[StringName,Callable] = {
	STATE_NONE: _on_null_function,
	STATE_SELECTED: _on_selected,
	STATE_MOVEMENT: _on_movement,
	STATE_CASTLING: _on_null_function,
	STATE_THREATENED: _on_threatened,
	STATE_CHECKED: _on_null_function,
	STATE_CHECKED_MOVEMENT: _on_null_function,
	STATE_CHECKING: _on_null_function,
}


static var _state_dict: Dictionary[StringName,Array] = {
	STATE_NONE: [],
	STATE_SELECTED: [],
	STATE_MOVEMENT: [],
	STATE_CASTLING: [],
	STATE_THREATENED: [],
	STATE_CHECKED: [],
	STATE_CHECKED_MOVEMENT: [],
	STATE_CHECKING: [],
}


var current: StringName = STATE_NONE


func _on_null_function(): pass
@abstract func _on_selected()
func _on_threatened(): pass
func _on_movement(): pass


static func remove_object_from_state_dict(object: InteractableGameObject):
	for key in _state_dict.keys():
		var list: Array = _state_dict.get(key)
		if object in list:
			list.erase(object)


static func get_objects_on_states(...state_names:Array) -> Array[InteractableGameObject]:
	var joint_array: Array[InteractableGameObject] = []
	for state_name:StringName in state_names:
		joint_array.append_array(_state_dict.get(state_name).filter(func(item): return is_instance_valid(item)))
	return joint_array


static func clear_intermediate_states():
	var object_array: Array[InteractableGameObject]
	object_array = get_objects_on_states(STATE_THREATENED,STATE_CASTLING,STATE_SELECTED,STATE_MOVEMENT)

	for object in object_array:
		object.state.set_state(STATE_NONE)


func _ready() -> void:
	_on_state_changed(STATE_NONE)


func set_state(new_state: StringName):
	_on_state_changed(new_state)
	state_changed.emit(current)


func _on_state_changed(new_state: StringName):
	_state_function_lookup.get(new_state).call()

	_state_dict.get(current).erase(get_parent())
	_state_dict.get(new_state).append(get_parent())

	current = new_state


func _apply_state_color(color: Color, enable_emission: bool = false):
	mesh_component.set_outline_color(color)
	mesh_component.outline_material.emission_enabled = enable_emission
	mesh_component.outline_material.emission = color


static func update_state_dict():
	for key in _state_dict.keys():
		var values: Array = _state_dict.get(key)
		var validity_checker_func: Callable = func(item) -> bool: return is_instance_valid(item)
		var new_values: Array = values.filter(validity_checker_func)
		_state_dict.set(key,new_values)

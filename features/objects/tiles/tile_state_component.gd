# keeps track of the states that each TileObject is in
class_name TileStateComponent
extends ObjectStateComponent


const state_color: Dictionary [StringName,Color] = {
	STATE_NONE: Color(1, 1, 1, 0),
	STATE_SELECTED: Color(0.1, 1, 1, 1),
	STATE_MOVEMENT: Color(0.6, 1, 0.6, 1),
	STATE_CASTLING: Color(1, 1, 1, 1),
	STATE_THREATENED: Color(1, 0.2, 0.2, 1),
	STATE_CHECKED: Color(1, 0.2, 0.2, 1),
	STATE_CHECKED_MOVEMENT: Color(1, 0.392, 0.153),
}


static func get_tiles_on_states(...state_names:Array) -> Array[TileObject]:
	var unfiltered_array: Array = get_objects_on_states.callv(state_names)
	var filtered_array: Array = unfiltered_array.filter(
			func(item) -> bool: return is_instance_valid(item) and item is TileObject
		)
	return filtered_array


func _on_state_changed(new_state: StringName):
	if new_state == current:
		new_state = STATE_NONE

	super._on_state_changed(new_state)

	if not state_color.has(new_state):
		printerr("Attempting to set {0} to an invalid state of {1}".format([get_parent().name,new_state]))
		return

	_apply_state_color(state_color.get(new_state))


func _on_selected():
	if TileObject.selection_mode == Constants.SelectionMode.SINGLE:
		var joint_array: Array = []
		joint_array = get_tiles_on_states(STATE_THREATENED,STATE_SELECTED,STATE_MOVEMENT)
		for selected_tile:TileObject in joint_array:
			selected_tile.state.set_state(STATE_NONE)
			if not is_instance_valid(selected_tile.occupant): continue
			selected_tile.occupant.state.set_state(ObjectStateComponent.STATE_NONE)

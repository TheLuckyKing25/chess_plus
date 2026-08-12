class_name PieceStateComponent
extends ObjectStateComponent


const state_color: Dictionary [StringName,Color] = {
	STATE_NONE: Color(1, 1, 1, 0),
	STATE_SELECTED: Color(0, 0.9, 0.9, 1),
	STATE_CASTLING: Color(1,1,1,1),
	STATE_THREATENED: Color(0.9, 0, 0, 1),
	STATE_CHECKED: Color(0.9, 0, 0, 1),
	STATE_CHECKING: Color(0.9, 0.9, 0),
}


static func get_pieces_on_states(...state_names:Array) -> Array[PieceObject]:
	var unfiltered_array: Array = get_objects_on_states.callv(state_names)
	var filtered_array: Array = unfiltered_array.filter(
			func(item) -> bool: return item is PieceObject
		)
	return filtered_array


func _on_state_changed(new_state: StringName):
	if new_state == current:
		new_state = STATE_NONE

	super(new_state)

	if state_color.has(new_state):
		_apply_state_color(state_color.get(new_state))
	else:
		printerr("Attempting to set ",get_parent().name," to an invalid state of ",new_state)


func _on_selected():
	if PieceObject.selection_mode == Constants.SelectionMode.SINGLE:
		var joint_array: Array = get_pieces_on_states(STATE_SELECTED,STATE_THREATENED)
		for selected_piece:PieceObject in joint_array:
			selected_piece.state.set_state(STATE_NONE)

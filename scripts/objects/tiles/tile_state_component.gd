# keeps track of the states that each TileObject is in
class_name TileStateComponent
extends ObjectStateComponent


const NONE_COLOR: Color = Color(1, 1, 1, 0)
const SELECT_COLOR: Color = Color(0.1, 1, 1, 1)
const VALID_COLOR: Color = Color(0.6, 1, 0.6, 1)
const CASTLING_COLOR: Color = Color(1, 1, 1, 1)
const THREATENED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const CHECKED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const MOVE_CHECKING_COLOR: Color = Color(1, 0.392, 0.153)


const color: Dictionary [Type,Color] = {
	Type.NONE: NONE_COLOR,
	Type.SELECTED: SELECT_COLOR,
	Type.MOVEMENT: VALID_COLOR,
	Type.CASTLING: CASTLING_COLOR,
	Type.THREATENED: THREATENED_COLOR,
	Type.CHECKED: CHECKED_COLOR,
	Type.CHECKED_MOVEMENT: MOVE_CHECKING_COLOR,
}

static var _state_dict: Dictionary[Type,Array] = {
	# Type : [TileObject, ... ]
	Type.NONE: [],
	Type.CHECKED_MOVEMENT: [],
	Type.CHECKED: [],
	Type.THREATENED: [],
	Type.CASTLING: [],
	Type.MOVEMENT: [],
	Type.SELECTED: [],
}


var tile: TileObject:
	get: return get_parent()


static func clear_intermediate_states():
	var intermediate_state_tiles: Array[TileObject] = []
	intermediate_state_tiles.append_array(_state_dict.get(Type.THREATENED))
	intermediate_state_tiles.append_array(_state_dict.get(Type.CASTLING))
	intermediate_state_tiles.append_array(_state_dict.get(Type.SELECTED))
	intermediate_state_tiles.append_array(_state_dict.get(Type.MOVEMENT))

	for tile_object in intermediate_state_tiles:
		tile_object.state.set_state(Type.NONE)


func _on_state_changed(new_state: Type):
	new_state = clamp(new_state,0,Type.keys().size()-1) as Type

	if new_state == current:
		new_state = Type.NONE

	_state_function_lookup.get(new_state).call()

	_state_dict.get(current).erase(tile)
	_state_dict.get(new_state).append(tile)

	current = new_state
	_apply_state_color()


func _apply_state_color():
	tile.set_state_color(color[current],false)


func _on_selected():
	if TileObject.selection_mode == Constants.SelectionMode.SINGLE:
		var joint_array: Array[TileObject] = []
		joint_array.append_array(_state_dict[Type.SELECTED])
		joint_array.append_array(_state_dict[Type.MOVEMENT])
		joint_array.append_array(_state_dict[Type.THREATENED])
		for selected_tile:TileObject in joint_array:
			selected_tile.state.set_state(Type.NONE)
			if is_instance_valid(selected_tile.occupant):
				selected_tile.occupant.state.set_state(ObjectStateComponent.Type.NONE)

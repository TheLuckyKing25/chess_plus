# keeps track of the states that each PieceObject is in
class_name PieceStateComponent
extends ObjectStateComponent

const NONE_COLOR: Color = Color(1, 1, 1, 0)
const SELECT_COLOR: Color = Color(0, 0.9, 0.9, 1)
const THREATENED_COLOR: Color = Color(0.9, 0, 0, 1)
const CHECKING_COLOR: Color = Color(0.9, 0.9, 0)
const CHECKED_COLOR: Color = Color(0.9, 0, 0, 1)
const CASTLING_COLOR: Color = Color(1,1,1,1)


@export var mesh_component: MeshComponent


const color: Dictionary [Type,Color] = {
	Type.NONE: NONE_COLOR,
	Type.SELECTED: SELECT_COLOR,
	Type.CASTLING: CASTLING_COLOR,
	Type.THREATENED: THREATENED_COLOR,
	Type.CHECKED: CHECKED_COLOR,
	Type.CHECKING: CHECKING_COLOR,
}


static var _state_dict: Dictionary[Type,Array] = {
	#Type : [PieceObject, ... ]
	Type.NONE: [],
	Type.CHECKING: [],
	Type.CHECKED: [],
	Type.THREATENED: [],
	Type.CASTLING: [],
	Type.SELECTED: [],
}


var piece: PieceObject:
	get: return get_parent()


static func clear_intermediate_states():
	var intermediate_state_pieces: Array[PieceObject] = []
	intermediate_state_pieces.append_array(_state_dict.get(Type.THREATENED))
	intermediate_state_pieces.append_array(_state_dict.get(Type.CASTLING))
	intermediate_state_pieces.append_array(_state_dict.get(Type.SELECTED))

	for piece_object in intermediate_state_pieces:
		piece_object.state.set_state(Type.NONE)


func _on_state_changed(new_state: Type):
	new_state = clamp(new_state,0,Type.keys().size()-1) as Type

	if new_state == current:
		new_state = Type.NONE

	_state_function_lookup.get(new_state).call()

	_state_dict.get(current).erase(piece)
	_state_dict.get(new_state).append(piece)

	current = new_state
	_apply_state_color()


func _apply_state_color():
	mesh_component.set_outline_color(color[current])
	mesh_component.outline_material.emission_enabled = false
	mesh_component.outline_material.emission = color[current]


func _on_selected():
	if PieceObject.selection_mode == Constants.SelectionMode.SINGLE:
		var joint_array: Array[PieceObject] = []
		joint_array.append_array(_state_dict[Type.SELECTED])
		joint_array.append_array(_state_dict[Type.THREATENED])
		for selected_piece:PieceObject in joint_array:
			selected_piece.state.set_state(Type.NONE)

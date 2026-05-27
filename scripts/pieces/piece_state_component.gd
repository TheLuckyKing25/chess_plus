# keeps track of the states that each PieceObject is in
class_name PieceStateComponent
extends Node


signal state_changed(new_state: Type)


const NONE_COLOR: Color = Color(1, 1, 1, 0)
const SELECT_COLOR:= Color(0, 0.9, 0.9, 1)
const THREATENED_COLOR:= Color(0.9, 0, 0, 1)
const CHECKING_COLOR:= Color(0.9, 0.9, 0)
const CHECKED_COLOR:= Color(0.9, 0, 0, 1)
const CASTLING_COLOR:= Color(1,1,1,1)


enum Type{
	NONE = 0,
	SELECTED = 1,
	MOVEMENT = 2, # unused by piece
	CASTLING = 3,
	THREATENED = 4,
	CHECKED = 5,
	CHECKED_MOVEMENT = 6, # unused by piece
	CHECKING = 7,
}


const color: Dictionary [Type,Color] = {
	Type.NONE: NONE_COLOR,
	Type.SELECTED: SELECT_COLOR,
	Type.CASTLING: CASTLING_COLOR,
	Type.THREATENED: THREATENED_COLOR,
	Type.CHECKED: CHECKED_COLOR,
	Type.CHECKING: CHECKING_COLOR,
}


var _state_function: Dictionary[Type,Callable] = {
	Type.NONE: _on_null_function,
	Type.SELECTED: _on_selected,
	Type.CASTLING: _on_null_function,
	Type.THREATENED: _on_null_function,
	Type.CHECKED: _on_null_function,
	Type.CHECKING: _on_null_function,
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
	get:
		return get_parent()


var current: Type


func _ready() -> void:
	_on_state_changed(Type.NONE)


func set_state(new_state: Type):
	_on_state_changed(new_state)
	state_changed.emit(current)


func _on_state_changed(new_state: Type):
	new_state = clamp(new_state,0,Type.keys().size()-1) as Type

	if new_state == current:
		new_state = Type.NONE

	_state_function.get(new_state).call()

	_state_dict[current].erase(piece)
	_state_dict[new_state].append(piece)

	current = new_state
	_apply_state_color()


func _apply_state_color():
	piece.set_state_color(color[current],false)


func _on_null_function():
	pass


func _on_selected():
	if PieceObject.selection_mode == Constants.SelectionMode.SINGLE:
		for selected_piece:PieceObject in _state_dict[Type.SELECTED]:
			selected_piece.state.set_state(Type.NONE)

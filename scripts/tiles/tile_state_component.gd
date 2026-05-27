# keeps track of the states that each TileObject is in
class_name TileStateComponent
extends Node


signal state_changed(new_state: Type)


enum Type{
	NONE = 0,
	SELECTED = 1,
	MOVEMENT = 2,
	CASTLING = 3,
	THREATENED = 4,
	CHECKED = 5,
	CHECKED_MOVEMENT = 6,
	CHECKING = 7, # unused by tiles
}


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


var _state_function: Dictionary[Type,Callable] = {
	Type.NONE: _on_null_function,
	Type.SELECTED: _on_selected,
	Type.MOVEMENT: _on_null_function,
	Type.CASTLING: _on_null_function,
	Type.THREATENED: _on_null_function,
	Type.CHECKED: _on_null_function,
	Type.CHECKED_MOVEMENT: _on_null_function,
}


static var _state_dict: Dictionary[Type,Array] = {
	#Type : [TileObject, ... ]
	Type.NONE: [],
	Type.CHECKED_MOVEMENT: [],
	Type.CHECKED: [],
	Type.THREATENED: [],
	Type.CASTLING: [],
	Type.MOVEMENT: [],
	Type.SELECTED: [],
}


var tile: TileObject:
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

	_state_dict[current].erase(tile)
	_state_dict[new_state].append(tile)

	current = new_state
	_apply_state_color()


func _apply_state_color():
	tile.set_state_color(color[current],false)


func _on_null_function():
	pass


func _on_selected():
	if TileObject.selection_mode == Constants.SelectionMode.SINGLE:
		for selected_tile:TileObject in _state_dict[Type.SELECTED]:
			selected_tile.state.set_state(Type.NONE)
			if selected_tile.occupant:
				selected_tile.occupant.state.set_state(PieceStateComponent.Type.NONE)

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


var function: Dictionary[Type,Callable] = {
	Type.NONE: Callable(self,"_on_invalid_function"),
	Type.SELECTED: Callable(self,"_on_selected"),
	Type.MOVEMENT: Callable(),
	Type.CASTLING: Callable(),
	Type.THREATENED: Callable(),
	Type.CHECKED: Callable(),
	Type.CHECKED_MOVEMENT: Callable(),
}


static var _state_dict: Dictionary[Type,Array] = {
	Type.NONE: [],
	Type.CHECKED_MOVEMENT: [],
	Type.CHECKED: [],
	Type.THREATENED: [],
	Type.CASTLING: [],
	Type.MOVEMENT: [],
	Type.SELECTED: [],
}


var current: Type = Type.NONE:
	set(value):
		if get_parent() == null:
			queue_free()

		state_changed.emit(value)

		current = value
		apply_state_color()


func _ready() -> void:
	state_changed.connect(Callable(self,"_on_state_changed"))


func set_state(new_state: Type):
	new_state = clamp(new_state,0,Type.keys().size()-1) as Type

	if new_state == current:
		new_state = Type.NONE

	function.get(new_state).call()

	_state_dict[current].erase(get_parent())
	_state_dict[new_state].append(get_parent())

	current = new_state



func _on_state_changed(new_state: Type):
	pass


func apply_state_color():
	get_parent().set_state_color(color[current],false)


func _on_invalid_function():
	pass


func _on_selected():
	if TileObject.selection_mode == Constants.SelectionMode.SINGLE:
		for tile:TileObject in _state_dict[Type.SELECTED]:
			tile.state.set_state(TileStateComponent.Type.NONE)
			if tile.occupant:
				tile.occupant.state.set_state(PieceStateComponent.Type.NONE)

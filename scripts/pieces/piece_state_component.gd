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
	CASTLING = 2,
	THREATENED = 3,
	CHECKED = 4,
	CHECKING = 5,
}


const color: Dictionary [Type,Color] = {
	Type.NONE: NONE_COLOR,
	Type.SELECTED: SELECT_COLOR,
	Type.CASTLING: CASTLING_COLOR,
	Type.THREATENED: THREATENED_COLOR,
	Type.CHECKED: CHECKED_COLOR,
	Type.CHECKING: CHECKING_COLOR,
}


var function: Dictionary[Type,Callable] = {
	Type.NONE: Callable(self,"_on_invalid_function"),
	Type.SELECTED: Callable(self,"_on_selected"),
	Type.CASTLING: Callable(),
	Type.THREATENED: Callable(),
	Type.CHECKED: Callable(),
	Type.CHECKING: Callable(),
}


static var _state_dict: Dictionary[Type,Array] = {
	Type.NONE: [],
	Type.CHECKING: [],
	Type.CHECKED: [],
	Type.THREATENED: [],
	Type.CASTLING: [],
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
	if PieceObject.selection_mode == Constants.SelectionMode.SINGLE:
		for piece:PieceObject in _state_dict[Type.SELECTED]:
			piece.state.current = PieceStateComponent.Type.NONE

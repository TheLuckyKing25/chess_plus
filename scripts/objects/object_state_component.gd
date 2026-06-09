@abstract class_name ObjectStateComponent
extends Node


signal state_changed(new_state: Type)


enum Type{
	NONE = 0,
	SELECTED = 1,
	MOVEMENT = 2, # unused by piece
	CASTLING = 3,
	THREATENED = 4,
	CHECKED = 5,
	CHECKED_MOVEMENT = 6, # unused by piece
	CHECKING = 7, # unused by tiles
}


var _state_function_lookup: Dictionary[Type,Callable] = {
	Type.NONE: _on_null_function,
	Type.SELECTED: _on_selected,
	Type.MOVEMENT: _on_movement,
	Type.CASTLING: _on_null_function,
	Type.THREATENED: _on_threatened,
	Type.CHECKED: _on_null_function,
	Type.CHECKED_MOVEMENT: _on_null_function,
	Type.CHECKING: _on_null_function,
}


var current: Type


static func clear_intermediate_states():
	PieceStateComponent.clear_intermediate_states()
	TileStateComponent.clear_intermediate_states()

func _ready() -> void:
	_on_state_changed(Type.NONE)


func set_state(new_state: Type):
	_on_state_changed(new_state)
	state_changed.emit(current)


func _on_null_function(): pass
func _on_selected(): pass
func _on_threatened(): pass
func _on_movement(): pass


@abstract func _on_state_changed(new_state: Type)

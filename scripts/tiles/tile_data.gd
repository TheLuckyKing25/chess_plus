# TileDataChess doesn't fit naming scheme of other Data classes
# because TileData is a Godot class
class_name TileDataChess
extends Resource

signal modifier_order_changed()

# Standard Tile Colors
const BASE_COLOR: Color = Color(0.75, 0.5775, 0.435, 1)
const LIGHT_COLOR: Color = BASE_COLOR * 4/3
const DARK_COLOR: Color = BASE_COLOR * 2/3 + Color(0,0,0,1)

# State Colors
const THREATENED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const VALID_COLOR: Color = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR: Color = Color(0.1, 1, 1, 1)
const CHECKED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const CASTLING_COLOR: Color = Color(1,1,1,1)
const MOVE_CHECKING_COLOR: Color = Color(1, 0.392, 0.153)

var modifier_order: Array[TileModifier] = []:
	set(new_order):
		modifier_order = new_order
		modifier_order_changed.emit()

#region Position
var board_position: Vector2i

var algebraic_notation: String:
	get():
		return char(97 + rank) + str((1 + file))

var rank: int:
	get():
		return board_position.x

var file: int:
	get():
		return board_position.y

var index: int
#endregion

#region States
var is_selected:bool = false:
	set(new_state):
		is_selected = new_state
		emit_changed()

var is_movement:bool = false:
	set(new_state):
		is_movement = new_state
		emit_changed()

var is_castling:bool = false:
	set(new_state):
		is_castling = new_state
		emit_changed()

var is_threatened:bool = false:
	set(new_state):
		is_threatened = new_state
		emit_changed()

var is_checked:bool = false:
	set(new_state):
		is_checked = new_state
		emit_changed()

var is_checked_movement:bool = false:
	set(new_state):
		is_checked_movement = new_state
		emit_changed()
#endregion


func _init() -> void:
	#self.index = index
	resource_local_to_scene = true

func clear_modifiers():
	modifier_order = []

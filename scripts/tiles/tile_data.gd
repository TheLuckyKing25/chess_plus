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
var rank: int

var file: int

var index: int

var algebraic_notation: String:
	get(): return char(97 + rank) + str((1 + file))

var board_position: Vector2i:
	set(value):
		rank = value.x
		file = value.y
	get():
		return Vector2i(rank,file)

#endregion


var flag: Dictionary[String, FlagComponent] = {
	"is_selected": FlagComponent.new(),
	"is_movement": FlagComponent.new(),
	"is_castling": FlagComponent.new(),
	"is_threatened": FlagComponent.new(),
	"is_checked": FlagComponent.new(),
	"is_checked_movement": FlagComponent.new(),
}


func connect_flag_changed_components(function:Callable):
	for component in flag.keys():
		flag[component].changed.connect(function)


func _init() -> void:
	resource_local_to_scene = true


func clear_modifiers():
	modifier_order = []


func get_tile_color() -> Color:
	match (file + rank) % 2:
		0: return LIGHT_COLOR
		1: return DARK_COLOR
		_: return Color(0,0,0)

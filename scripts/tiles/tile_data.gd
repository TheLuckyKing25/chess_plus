# TileDataChess doesn't fit naming scheme of other Data classes
# because TileData is a Godot class
class_name TileDataChess
extends Resource

signal modifier_order_changed()
signal occupant_changed(occupant: PieceData)


var flag: Dictionary = {
	"is_selected": FlagComponent.new(),
	"is_movement": FlagComponent.new(),
	"is_castling": FlagComponent.new(),
	"is_threatened": FlagComponent.new(),
	"is_checked": FlagComponent.new(),
	"is_checked_movement": FlagComponent.new(),
}


var modifier_order: Array[TileModifier] = []:
	set(new_order):
		modifier_order = new_order
		modifier_order_changed.emit()


var neighbors: Dictionary[Movement.Direction, TileDataChess] = {
	Movement.Direction.NORTH: null,
	Movement.Direction.NORTHEAST: null,
	Movement.Direction.EAST: null,
	Movement.Direction.SOUTHEAST: null,
	Movement.Direction.SOUTH: null,
	Movement.Direction.SOUTHWEST: null,
	Movement.Direction.WEST: null,
	Movement.Direction.NORTHWEST: null,
}

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


var occupant: PieceObject = null:
	set(new_occupant):
		occupant = new_occupant
		occupant_changed.emit(new_occupant)


var assigned_object: TileObject


func _init() -> void:
	resource_local_to_scene = true


func connect_flag_changed_components(function:Callable):
	for component in flag.keys():
		flag[component].changed.connect(function)


func clear_modifiers():
	modifier_order = []


func change(flag:String, enabled:bool):
	self.flag[flag].enabled = enabled
	if occupant and occupant.data.flag.has(flag):
		occupant.data.flag[flag].enabled = enabled


func clear_flags():
	change("is_selected",false)
	change("is_threatened",false)
	change("is_castling",false)
	change("is_checked_movement", false)
	change("is_movement", false)


func clear_check_flag():
	change("is_checked",false)

func set_position_data(index:int, vector: Vector2i):
	self.index = index
	rank = vector.x
	file = vector.y

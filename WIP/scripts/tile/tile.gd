@tool
class_name Tile extends Resource

@export var position: Dictionary[String,Variant] = {
	"index": -1,
	"vector": Vector2i(-1,-1),
	"algebraic_notation": "__",
	"rank": -1,
	"file": -1,
}

var occupant: Piece = null


var is_occupied: bool:
	get(): return occupant != null


@export var neighbors: Dictionary[Constants.Direction, Tile] = {
	Constants.Direction.NORTH: null,
	Constants.Direction.NORTHEAST: null,
	Constants.Direction.EAST: null,
	Constants.Direction.SOUTHEAST: null,
	Constants.Direction.SOUTH: null,
	Constants.Direction.SOUTHWEST: null,
	Constants.Direction.WEST: null,
	Constants.Direction.NORTHWEST: null,
}

var modifiers: Array = []


var flag: Dictionary[String, FlagComponent] = {
	"is_selected": FlagComponent.new(),
	"is_movement": FlagComponent.new(),
	"is_castling": FlagComponent.new(),
	"is_threatened": FlagComponent.new(),
	"is_checked": FlagComponent.new(),
	"is_checked_movement": FlagComponent.new(),
}


func connect_flag_components(function:Callable):
	for component in flag.keys():
		flag[component].changed.connect(function)


func _init() -> void:
	resource_local_to_scene = true


func clear_modifiers():
	modifiers = []

func set_position_data(index:int, vector: Vector2i):
	position.index = index
	position.vector = vector
	position.rank = vector.x
	position.file = vector.y
	position.algebraic_notation = char(97 + vector.x) + str((1 + vector.y))
	resource_name = position.algebraic_notation

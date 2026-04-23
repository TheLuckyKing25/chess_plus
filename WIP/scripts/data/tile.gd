@tool
class_name Tile extends Resource

@export var position: Dictionary = {
	"index": -1,
	"vector": Vector2i(-1,-1),
	"algebraic_notation": "__",
	"rank": -1,
	"file": -1,
}


var algebraic_notation: String:
	get(): return char(97 + rank) + str((1 + file))


var rank: int:
	get(): return position.vector.x


var file: int:
	get(): return  position.vector.y


var occupant: Piece = null


var is_occupied: bool:
	get(): return occupant != null


@export var neighbors: Dictionary[Movement.Direction, Tile] = {
	Movement.Direction.NORTH: null,
	Movement.Direction.NORTHEAST: null,
	Movement.Direction.EAST: null,
	Movement.Direction.SOUTHEAST: null,
	Movement.Direction.SOUTH: null,
	Movement.Direction.SOUTHWEST: null,
	Movement.Direction.WEST: null,
	Movement.Direction.NORTHWEST: null,
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
	position.algebraic_notaion = char(97 + vector.x) + str((1 + vector.y))
	resource_name = char(97 + vector.x) + str((1 + vector.y))

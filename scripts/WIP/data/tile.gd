class_name Tile extends Resource

var position: Dictionary = {
	"vector": Vector2i(-1,-1),
	"index": -1,
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


var neighbors: Dictionary[Movement.Direction, Tile] = {
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

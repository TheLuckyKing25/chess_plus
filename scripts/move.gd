class_name Move
extends Resource

enum Type{
	MOVING = 0,
	THREATENING = 1,
	CASTLING = 2,
	JUMPING = 3,
}

enum Outcome{
	IGNORE = 0,
	MOVE = 1,
	CAPTURING = 2,
	PROMOTION = 4,
	CHECK = 8,
	CHECKMATE = 16,
	CASTLING_QUEENSIDE = 32,
	CASTLING_KINGSIDE = 64,
	EN_PASSANT = 128,
}

var starting_tile: TileObject


var destination_tile: TileObject


var type_flags: int


var outcome_flags: int


func _init(start: TileObject, destination: TileObject, flags:int = Outcome.MOVE) -> void:
	starting_tile = start
	destination_tile = destination
	outcome_flags = flags

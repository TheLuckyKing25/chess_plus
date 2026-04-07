class_name Move
extends Resource

enum Type{
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

# temp variable
var array_notation:Array[TileObject]:
	get():
		return [starting_tile, destination_tile]

var flags: int


func _init(start: TileObject, destination: TileObject, flags:int = Type.MOVE) -> void:
	starting_tile = start
	destination_tile = destination
	self.flags = flags

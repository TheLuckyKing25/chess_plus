# Constants Autoload
# contains values that need to be accessed in multiple locations
extends Node

enum SelectionMode{
	SINGLE = 0,
	MULTIPLE = 1,
}


enum Direction{
	NORTH = 0,
	NORTHEAST = 1,
	EAST = 2,
	SOUTHEAST = 3,
	SOUTH = 4,
	SOUTHWEST = 5,
	WEST = 6,
	NORTHWEST = 7,
	}


const DIRECTION_VECTOR: Dictionary[Direction, Vector2i] = {
	Direction.NORTH: Vector2i(1,0),
	Direction.NORTHEAST: Vector2i(1,1),
	Direction.EAST: Vector2i(0,1),
	Direction.SOUTHEAST: Vector2i(-1,1),
	Direction.SOUTH: Vector2i(-1,0),
	Direction.SOUTHWEST: Vector2i(-1,-1),
	Direction.WEST: Vector2i(0,-1),
	Direction.NORTHWEST: Vector2i(1,-1)
}


enum TypePiece{
	PAWN,
	BISHOP,
	KING,
	QUEEN,
	KNIGHT,
	ROOK,
}


const PIECE_SCENE_UID_DICT: Dictionary[TypePiece,String] = {
	TypePiece.PAWN: "uid://cjvj8f6rpuk0k",
	TypePiece.BISHOP: "uid://b7fydri8mw0oj",
	TypePiece.KING: "uid://dwrbcnxvnk3jn",
	TypePiece.QUEEN: "uid://y6vdamvltd7x",
	TypePiece.KNIGHT: "uid://boe1ns6dsv6qi",
	TypePiece.ROOK: "uid://bpaf3sb1uhi38",
}


@abstract
class TURN_TRANSITION:
	const DELAY_SECONDS:float = 0.25
	const DURATION_SECONDS:float = 0.5


@abstract
class GROUPS:
	const PIECE:StringName = &"Piece"
	const TILE:StringName = &"Tile"

	const IS_OCCUPIED:StringName = &"isOccupied"
	const IS_RULED:StringName = &"isRuled"
	const HAS_MOVED:StringName = &"hasMoved"


	static var threatenable_groups: Array[StringName] = [IS_OCCUPIED]

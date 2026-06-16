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


enum TypePiece{
	PAWN = 0,
	BISHOP = 1,
	KING = 2,
	QUEEN = 3,
	KNIGHT = 4,
	ROOK = 5,
}

# generated upon ready
var piece_type: Dictionary = {}

# generated upon ready
var player_data: Dictionary[String, String] = {}


const DIRECTION_VECTOR: Dictionary[Constants.Direction, Vector2i] = {
	Constants.Direction.NORTH: Vector2i(1,0),
	Constants.Direction.NORTHEAST: Vector2i(1,1),
	Constants.Direction.EAST: Vector2i(0,1),
	Constants.Direction.SOUTHEAST: Vector2i(-1,1),
	Constants.Direction.SOUTH: Vector2i(-1,0),
	Constants.Direction.SOUTHWEST: Vector2i(-1,-1),
	Constants.Direction.WEST: Vector2i(0,-1),
	Constants.Direction.NORTHWEST: Vector2i(1,-1)
}


enum DirectoryRefNum{
	PLAYER_DATA = 0,
	PIECE_TYPE = 1,
}


const file_path: Dictionary = {
	DirectoryRefNum.PLAYER_DATA: "res://resources/player/",
	DirectoryRefNum.PIECE_TYPE: "res://resources/pieces/type/",
}


const TURN_TRANSITION_DELAY_SECONDS:float = 0.25
const TURN_TRANSITION_TIME_SECONDS:float = 0.5


func _ready() -> void:
	_retrieve_player_data()
	_retrieve_piece_types()


func _retrieve_player_data():
	var data = ResourceLoader.list_directory(file_path.get(DirectoryRefNum.PLAYER_DATA))
	for player in data:
		var file_string:String = file_path.get(DirectoryRefNum.PLAYER_DATA) + player
		var loaded_data:PlayerData = load(file_string)
		var uid:int = ResourceLoader.get_resource_uid(file_string)

		player_data.set(loaded_data.player_name.to_lower(),ResourceUID.id_to_text(uid))


func _retrieve_piece_types():
	var data = ResourceLoader.list_directory(file_path.get(DirectoryRefNum.PIECE_TYPE))
	for piece in data:
		var file_string:String = file_path.get(DirectoryRefNum.PIECE_TYPE) + piece
		var loaded_data:PieceType = load(file_string)
		var uid:int = ResourceLoader.get_resource_uid(file_string)
		var constant_identifier: TypePiece = TypePiece[loaded_data.name.to_upper()]
		piece_type.set(constant_identifier,ResourceUID.id_to_text(uid))

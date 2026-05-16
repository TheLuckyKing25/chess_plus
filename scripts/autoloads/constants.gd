# Constants Autoload
# contains values that are considered constants and need to be accessed throughout the game
extends Node

enum TypePiece{
	PAWN = 0,
	BISHOP = 1,
	KING = 2,
	QUEEN = 3,
	KNIGHT = 4,
	ROOK = 5,
}

enum GameColor{
	THREATENED,
	VALID,
	SELECT,
	CHECKED,
	CASTLING,
	MOVE_CHECKING,
}


const piece_type: Dictionary = {
	TypePiece.PAWN: "uid://bih6lr0cwxuk",
	TypePiece.BISHOP: "uid://b7mqdwuvfi3nh",
	TypePiece.KING: "uid://bfy5ow4fdbo1l",
	TypePiece.QUEEN: "uid://oqdygo3fdmd2",
	TypePiece.KNIGHT: "uid://cgvt2kihfm4em",
	TypePiece.ROOK: "uid://csqiux6uupcb2",
}


const tile_color_dict: Dictionary = {
	GameColor.THREATENED: Color(1, 0.2, 0.2, 1),
	GameColor.VALID: Color(0.6, 1, 0.6, 1),
	GameColor.SELECT: Color(0.1, 1, 1, 1),
	GameColor.CHECKED: Color(1, 0.2, 0.2, 1),
	GameColor.CASTLING: Color(1,1,1,1),
	GameColor.MOVE_CHECKING: Color(1, 0.392, 0.153),
}

# Reference Autoload
# Contains all references to other files.
extends Node

enum {
	PIECE_TYPE_PAWN,
	PIECE_TYPE_BISHOP,
	PIECE_TYPE_KING,
	PIECE_TYPE_QUEEN,
	PIECE_TYPE_KNIGHT,
	PIECE_TYPE_ROOK,
}

var piece_type: Dictionary = {
	PIECE_TYPE_PAWN: "uid://bih6lr0cwxuk",
	PIECE_TYPE_BISHOP: "uid://b7mqdwuvfi3nh",
	PIECE_TYPE_KING: "uid://bfy5ow4fdbo1l",
	PIECE_TYPE_QUEEN: "uid://oqdygo3fdmd2",
	PIECE_TYPE_KNIGHT: "uid://cgvt2kihfm4em",
	PIECE_TYPE_ROOK: "uid://csqiux6uupcb2",
}

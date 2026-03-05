class_name Move
extends Resource

const ALGEBRAIC_NOTATION_CASTLING_KINGSIDE = "O-O"
const ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE = "O-O-O"
const ALGEBRAIC_NOTATION_CHECK = "+"
const ALGEBRAIC_NOTATION_CHECKMATE = "#"
const ALGEBRAIC_NOTATION_PROMOTION = "="
const ALGEBRAIC_NOTATION_CAPTURE = "x"

var starting_tile: TileObject

var destination_tile: TileObject

# temp variable
var array_notation:Array[TileObject]:
	get():
		return [starting_tile,destination_tile]


var algebraic_notation: String:
	get():
		return ""


func _init(start: TileObject, destination: TileObject):
	starting_tile = start
	destination_tile = destination



func get_algebraic_notation():
	pass

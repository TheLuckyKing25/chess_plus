class_name Move
extends Resource

const ALGEBRAIC_NOTATION_EN_PASSANT = "e.p."
const ALGEBRAIC_NOTATION_CASTLING_KINGSIDE = "O-O"
const ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE = "O-O-O"
const ALGEBRAIC_NOTATION_CHECK = "+"
const ALGEBRAIC_NOTATION_CHECKMATE = "#"
const ALGEBRAIC_NOTATION_PROMOTION = "="
const ALGEBRAIC_NOTATION_CAPTURE = "x"

enum Type{
	IGNORE = 0,				#00000000
	MOVE = 1, 				#00000001
	CAPTURING = 2, 			#00000010
	PROMOTION = 4,			#00000100
	CHECK = 8,				#00001000
	CHECKMATE = 16,			#00010000
	CASTLING_QUEENSIDE = 32,#00100000
	CASTLING_KINGSIDE = 64,	#01000000
	EN_PASSANT = 128,		#10000000
}

var starting_tile: TileObject:
	set(start):
		# notation starts with piece identifier and starting tile location
		if start.occupant:
			_notation_prefix = (
					start.occupant.data.algebraic_notation
					+ start.data.algebraic_notation
					)
		starting_tile = start


var destination_tile: TileObject:
	set(destination):
		# include destination tile to notation output
		_notation_suffix += destination.data.algebraic_notation
		destination_tile = destination

# temp variable
var array_notation:Array[TileObject]:
	get():
		return [starting_tile, destination_tile]

var _notation_prefix:String = ""

var _notation_middle:String = ""

var _notation_suffix:String = ""

var algebraic_notation: String:
	get():
		if flags == Type.IGNORE:
			return ""
		elif flags & Type.CASTLING_QUEENSIDE:
			return ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE

		elif flags & Type.CASTLING_KINGSIDE:
			return ALGEBRAIC_NOTATION_CASTLING_KINGSIDE
		else:
			return _notation_prefix + _notation_middle + _notation_suffix

var flags: int:
	set(new_flags):

		# placed between start and destination tile location
		if new_flags & Type.CAPTURING:
			_notation_middle += ALGEBRAIC_NOTATION_CAPTURE

		if new_flags & Type.CHECK:
			_notation_suffix += ALGEBRAIC_NOTATION_CHECK
		elif new_flags & Type.CHECKMATE:
			_notation_suffix += ALGEBRAIC_NOTATION_CHECKMATE

		if new_flags & Type.EN_PASSANT:
			_notation_suffix += " " + ALGEBRAIC_NOTATION_EN_PASSANT
		elif new_flags & Type.PROMOTION:
			_notation_suffix += ALGEBRAIC_NOTATION_PROMOTION
		flags = new_flags


func _init(start: TileObject, destination: TileObject, flags:int = Type.MOVE) -> void:
	starting_tile = start
	destination_tile = destination
	self.flags = flags

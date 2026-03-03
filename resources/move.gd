class_name Move
extends Resource

const ALGEBRAIC_NOTATION_CASTLING_KINGSIDE = "O-O"
const ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE = "O-O-O"
const ALGEBRAIC_NOTATION_CHECK = "+"
const ALGEBRAIC_NOTATION_CHECKMATE = "#"
const ALGEBRAIC_NOTATION_PROMOTION = "="
const ALGEBRAIC_NOTATION_CAPTURE = "x"

var starting_tile: TileController

var destination_tile: TileController


# temp variable
var array_notation:Array[TileController]:
	get():
		return [starting_tile,destination_tile]


var algebraic_notation: String:
	get():
		return ""


func _init(start: TileController, destination: TileController):
	starting_tile = start
	destination_tile = destination


func make_virtual_move():
	destination_tile.occupant = starting_tile.occupant
	starting_tile.occupant = null


func unmake_virtual_move():
	starting_tile.occupant = destination_tile.occupant
	destination_tile.occupant = BoardController.stats.piece_location[destination_tile.stats.index]


func get_algebraic_notation():
	pass


func is_legal():
	var is_legal:bool = true
	make_virtual_move()
	
	var opponent_moves: Array[Move] = BoardStats.generate_all_moves(Board.stats.get_opponent_of(Player.current))
	for opposing_move in opponent_moves:
		if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces[PieceKing.name][0]:
			is_legal = false
			break
	
	unmake_virtual_move()
	
	if is_legal:
		return true

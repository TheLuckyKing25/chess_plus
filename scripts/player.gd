class_name Player
extends Resource

## The player whose turn it is
static var current: Player
static var previous: Player

static var en_passant: Player

## Unused. 
## Can be used with more than two players where turn order matters.
static var turn_order: Array

## Used to group the pieces belonging to the player
@export var name:String

@export var color:Color

var pieces:Dictionary[String,Array] = {
	
}

var all_pieces: Array[Piece]:
	get():
		var array: Array[Piece] = []
		for piece_type in pieces.keys():
			array.append_array(pieces[piece_type])
		return array


func add_piece(new_piece: Piece):
	if pieces.has(new_piece.name):
		pieces[new_piece.name].append(new_piece)
	else:
		pieces[new_piece.name] = [new_piece]

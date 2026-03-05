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

var all_pieces: Array[PieceObject]:
	get():
		var array: Array[PieceObject] = []
		for piece_type in pieces.keys():
			array.append_array(pieces[piece_type])
		return array


func add_piece(new_piece: PieceObject):
	if pieces.has(new_piece.data.name):
		pieces[new_piece.data.name].append(new_piece)
	else:
		pieces[new_piece.data.name] = [new_piece]

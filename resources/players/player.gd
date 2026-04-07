class_name Player
extends Resource

## The player whose turn it is
static var current: Player

## The player whose turn it is was
## Used to determine the start and end of camera animations at turn transitions
static var previous: Player


static var en_passant: Player


## Unused.
## Can be used with more than two players where turn order matters.
static var turn_order: Array


## Used to group the pieces belonging to the player
@export var name:String


@export var color:Color


@export var pieces:Dictionary[String,Array] = {}


## determines which direction to face the piece
@export var parity: int

## Used to rotate the movement of the piece
@export var direction_parity: int

# rank that pieces are promoted
var promotion_rank: int


var all_pieces: Array[PieceObject]:
	get():
		var array: Array[PieceObject] = []
		for piece_type in pieces.keys():
			array.append_array(pieces[piece_type])
		return array


var timer: TimeControl


func add_piece(new_piece: PieceObject) -> void:
	if pieces.has(new_piece.data.name):
		pieces[new_piece.data.name].append(new_piece)
	else:
		pieces[new_piece.data.name] = [new_piece]

func remove_piece(piece:PieceObject) -> void:
	if pieces.has(piece.data.name):
		pieces[piece.data.name].erase(piece)

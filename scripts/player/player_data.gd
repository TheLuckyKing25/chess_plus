class_name PlayerData
extends Resource

signal piece_list_changed()

@export var player_name:String
@export var color:Color

## determines which direction to face the piece
@export var parity: int:
	set(value):
		direction_parity = remap(value,-1,1,4,0)
		piece_rotation_parity = remap(value,-1,1,0,PI)
		parity = value

## Used to rotate the movement of the piece
var direction_parity: int


var piece_rotation_parity: float


var assigned_object: Player


@export var pieces:Dictionary[String,Array] = {}


# rank that a piece must reach to be promoted
var promotion_rank: int


var all_pieces: Array[PieceObject]:
	get():
		var array: Array[PieceObject] = []
		for piece_types in pieces.values():
			array.append_array(piece_types)
		return array


#func add_piece(new_piece: PieceObject) -> void:
	#if pieces.has(new_piece.data.type.name):
		#pieces[new_piece.data.type.name].append(new_piece)
	#else:
		#pieces[new_piece.data.type.name] = [new_piece]
#
#
#func remove_piece(piece:PieceObject) -> void:
	#if pieces.has(piece.data.type.name):
		#pieces[piece.data.type.name].erase(piece)

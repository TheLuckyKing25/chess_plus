class_name Player
extends Node

## The player whose turn it is
static var current: Player

## The player whose turn it is was
## Used to determine the start and end of camera animations at turn transitions
static var previous: Player


static var en_passant: Player


signal piece_list_changed()


@export var player_name:String
@export var color:Color

## determines which direction to face the piece object
@export var parity: int:
	set(value):
		facing_direction = int(remap(value,-1,1,4,0)) as Constants.Direction
		piece_rotation_parity = remap(value,-1,1,0,PI)
		parity = value

## Used to rotate the movement of the piece
var facing_direction: Constants.Direction


var piece_rotation_parity: float


@export var pieces:Dictionary[String,Array] = {}


# rank that a piece must reach to be promoted
var promotion_rank: int


@export var camera_component: CameraComponent

@export var timer: TimeControl


var all_pieces: Array[PieceObject]:
	get:
		var array: Array[PieceObject] = []
		for piece_configs in pieces.values():
			array.append_array(piece_configs)
		return array


func _ready() -> void:
	GameData.players.set(player_name.to_lower(),self)

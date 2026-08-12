class_name Player
extends Node


@export var player_name: StringName
@export var color:Color


@export var parity: int:
	set(value):
		facing_direction = int(remap(value,-1,1,4,0)) as Constants.Direction
		piece_rotation_parity = remap(value,-1,1,0,PI)
		parity = value


@export var camera_component: CameraComponent


@export var timer: TimeControl


## determines which direction to face the piece object
var facing_direction: Constants.Direction


var piece_rotation_parity: float


# rank that a piece must reach to be promoted
var promotion_rank: int


var group_name: StringName:
	get: return "Player_" + player_name


var all_pieces: Array[PieceObject]:
	get: return get_tree().get_nodes_in_group(group_name) as Array[PieceObject]

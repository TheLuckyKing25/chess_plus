class_name Player
extends Node

## The player whose turn it is
static var current: Player

## The player whose turn it is was
## Used to determine the start and end of camera animations at turn transitions
static var previous: Player


static var en_passant: Player

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

@export_group("Camera", "camera")
@export var camera_object: Camera3D
@export_custom(
		PROPERTY_HINT_RANGE,
		"0,20, 0.05, or_less,or_greater, suffix: m"
	) var camera_distance_from_subject:float = 0

@export var camera_twist_pivot: Node3D
@export_custom(
		PROPERTY_HINT_RANGE,
		"-360,360,0.1, degrees, suffix:°",
		PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE
	) var camera_yaw: float = 0.0


@export var camera_pitch_pivot: Node3D
@export_custom(
		PROPERTY_HINT_RANGE,
		"-90,90,0.1, degrees, suffix:°"
	) var camera_pitch: float = 0.0


@export var camera_horizonatal_offset: float = 0
@export var camera_forward_offset: float = 0


@export_group("Timer")
@export var timer: TimeControl


var pieces:Dictionary[String,Array] = {}


# rank that a piece must reach to be promoted
var promotion_rank: int


var all_pieces: Array[PieceObject]:
	get():
		var array: Array[PieceObject] = []
		for piece_types in pieces.values():
			array.append_array(piece_types)
		return array


func _ready() -> void:
	GameData.player.set(player_name.to_lower(),self)



func _process(_delta: float) -> void:
	camera_object.position.z = camera_distance_from_subject
	camera_pitch_pivot.rotation_degrees.x = camera_pitch
	camera_twist_pivot.rotation_degrees.y = camera_yaw
	camera_twist_pivot.position.x = camera_horizonatal_offset
	camera_twist_pivot.position.z = camera_forward_offset


func add_piece(new_piece: PieceObject) -> void:
	if pieces.has(new_piece.data.type.name):
		pieces[new_piece.data.type.name].append(new_piece)
	else:
		pieces[new_piece.data.type.name] = [new_piece]


func remove_piece(piece:PieceObject) -> void:
	if pieces.has(piece.data.type.name):
		pieces[piece.data.type.name].erase(piece)


func change_camera_forward_offset(value:float):
	camera_forward_offset = value * parity


func change_camera_horizontal_offset(value:float):
	camera_horizonatal_offset = value * parity

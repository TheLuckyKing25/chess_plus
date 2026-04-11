@tool
class_name Player
extends Node

## The player whose turn it is
static var current: Player

## The player whose turn it is was
## Used to determine the start and end of camera animations at turn transitions
static var previous: Player


static var en_passant: Player

## Unused.
## Can be used with more than two players where turn order matters.
#static var turn_order: Array


@export var color:Color

@export var pieces:Dictionary[String,Array] = {}


## determines which direction to face the piece
@export var parity: int

## Used to rotate the movement of the piece
@export var direction_parity: int

@export_group("Camera", "camera")
@export var camera_camera: Camera3D
@export_custom(
		PROPERTY_HINT_RANGE,
		"0,20, 0.05, or_less,or_greater, suffix: m"
		) var camera_distance_from_subject:float = 0
@export_custom(
		PROPERTY_HINT_RANGE,
		"-360,360,0.1, degrees, suffix:°",
		PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE
		) var camera_yaw: float = 0.0
@export_custom(
		PROPERTY_HINT_RANGE,
		"-90,90,0.1, degrees, suffix:°"
		) var camera_pitch: float = 0.0
@export var camera_horizonatal_offset: float = 0
@export var camera_forward_offset: float = 0


@export_group("Timer")
@export var timer: TimeControl


# rank that pieces are promoted
var promotion_rank: int


var all_pieces: Array[PieceObject]:
	get():
		var array: Array[PieceObject] = []
		for piece_type in pieces.keys():
			array.append_array(pieces[piece_type])
		return array


func _ready() -> void:
	Match.players[name.to_lower()] = self


func _process(_delta: float) -> void:
	camera_camera.position.z = camera_distance_from_subject
	$TwistPivot/PitchPivot.rotation_degrees.x = camera_pitch
	$TwistPivot.rotation_degrees.y = camera_yaw
	$TwistPivot.position.x = camera_horizonatal_offset
	$TwistPivot.position.z = camera_forward_offset


func add_piece(new_piece: PieceObject) -> void:
	if pieces.has(new_piece.data.name):
		pieces[new_piece.data.name].append(new_piece)
	else:
		pieces[new_piece.data.name] = [new_piece]


func remove_piece(piece:PieceObject) -> void:
	if pieces.has(piece.data.name):
		pieces[piece.data.name].erase(piece)


func change_camera_forward_offset(value:float):
	camera_forward_offset = value * parity


func change_camera_horizontal_offset(value:float):
	camera_horizonatal_offset = value * parity

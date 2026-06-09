class_name Player
extends Node

## The player whose turn it is
static var current: Player

## The player whose turn it is was
## Used to determine the start and end of camera animations at turn transitions
static var previous: Player


static var en_passant: Player


@export var data: PlayerData:
	set(value):
		if data:
			data.assigned_object = null
			GameData.players.erase(data.player_name.to_lower())
		if value:
			value.assigned_object = self
			GameData.players.set(value.player_name.to_lower(),self)
		data = value


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


func _ready() -> void:
	GameData.players.set(data.player_name.to_lower(),self)


func _process(_delta: float) -> void:
	camera_object.position.z = camera_distance_from_subject
	camera_pitch_pivot.rotation_degrees.x = camera_pitch
	camera_twist_pivot.rotation_degrees.y = camera_yaw
	camera_twist_pivot.position.x = camera_horizonatal_offset
	camera_twist_pivot.position.z = camera_forward_offset


func change_camera_forward_offset(value:float):
	camera_forward_offset = value * data.parity


func change_camera_horizontal_offset(value:float):
	camera_horizonatal_offset = value * data.parity

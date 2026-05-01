class_name CameraComponent
extends Node

@export var twist_pivot: Node3D
@export var pitch_pivot: Node3D
@export var camera: Camera3D

@export_custom(
		PROPERTY_HINT_RANGE,
		"0,20, 0.05, or_less,or_greater, suffix: m"
		) var distance_from_subject:float = 0


@export_custom(
		PROPERTY_HINT_RANGE,
		"-360,360,0.1, degrees, suffix:°",
		PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE
		) var yaw: float = 0.0


@export_custom(
		PROPERTY_HINT_RANGE,
		"-90,90,0.1, degrees, suffix:°"
		) var pitch: float = 0.0

@export var horizonatal_offset: float = 0
@export var forward_offset: float = 0

func _process(_delta: float) -> void:
	camera.position.z = distance_from_subject
	pitch_pivot.rotation_degrees.x = pitch
	twist_pivot.rotation_degrees.y = yaw
	twist_pivot.position.x = horizonatal_offset
	twist_pivot.position.z = forward_offset

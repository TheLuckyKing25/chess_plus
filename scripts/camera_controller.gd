@tool
extends Node3D

@export_custom(PROPERTY_HINT_RANGE,"0,20, 0.05,or_less,or_greater, suffix: m") var distance_from_subject:float = 0

@export_custom(PROPERTY_HINT_RANGE,"-360,360,0.1,degrees, suffix:°",PROPERTY_USAGE_DEFAULT|PROPERTY_USAGE_SCRIPT_VARIABLE) var yaw: float = 0.0

@export_custom(PROPERTY_HINT_RANGE,"-90,90,0.1, degrees, suffix:°") var pitch: float = 0.0

@export var horizonatal_offset: float = 0

@export var forward_offset: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PitchPivot/Camera.position.z = distance_from_subject
	$PitchPivot.rotation_degrees.x = pitch
	rotation_degrees.y = yaw
	position.x = horizonatal_offset
	position.z = forward_offset

func make_current() -> void:
	$PitchPivot/Camera.make_current()

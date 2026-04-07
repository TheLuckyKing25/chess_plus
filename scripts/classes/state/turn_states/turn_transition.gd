class_name TurnTransition
extends State

@export var from_camera: Node3D
@export var to_camera: Node3D
@export var initial_rotation_degree: int
@export var next_state: State

var camera_rotation: float = 0
var can_proceed = false

func enter():
	print_debug(name, " enter")
	if NetworkManager.is_online:
		transitioned.emit(self,next_state.name)

func exit():
	print_debug(name, " exit")
	from_camera.yaw = 180
	to_camera.make_current()
	if from_camera.yaw != initial_rotation_degree:
		from_camera.yaw = initial_rotation_degree
	camera_rotation = 0
	can_proceed = false

func update(_delta:float):
	if Match.board_object._time_elapsed_since_turn_ended > 0:
		can_proceed = true
	if can_proceed and Match.board_object._time_elapsed_since_turn_ended * BoardData.TURN_TRANSITION_SPEED <= 1:
		camera_rotation += 180 * BoardData.TURN_TRANSITION_SPEED * _delta * 1000
		from_camera.yaw = camera_rotation + initial_rotation_degree
		if camera_rotation >= 180:
			transitioned.emit(self,next_state.name)

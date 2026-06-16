class_name TurnTransition
extends State

@export var previous_state: PlayerTurn
@export var initial_rotation_degree: int
@export var next_state: PlayerTurn

@onready var camera_ending_yaw = previous_state.player.camera_yaw + 180

var camera_rotation: float = 0
var can_proceed = false

func enter():
	DebugPrinter.print_state_enter(name)

	if not GameData.match_settings.skip_transition_animation:
		await get_tree().create_timer(Constants.TURN_TRANSITION_DELAY_SECONDS).timeout
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(
				previous_state.player,
				"camera_yaw",
				camera_ending_yaw,
				Constants.TURN_TRANSITION_TIME_SECONDS
			)
		tween.tween_property(
				previous_state.board.board_base.material_override,
				"albedo_color",
				next_state.player.data.color,
				 Constants.TURN_TRANSITION_TIME_SECONDS)
		await tween.finished

	transitioned.emit(self,next_state.name)

func exit():
	next_state.player.camera_object.make_current()
	previous_state.player.camera_yaw = initial_rotation_degree

	DebugPrinter.print_state_exit(name)

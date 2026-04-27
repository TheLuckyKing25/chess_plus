class_name TurnTransition
extends State

@export var previous_state: PlayerTurn
@export var initial_rotation_degree: int
@export var next_state: PlayerTurn

var camera_rotation: float = 0
var can_proceed = false

func enter():
	#print_rich("[b][color=web_green]Entered[/color]: [/b]",name)
	if NetworkManager.is_online:
		transitioned.emit(self,next_state.name)
	Match.game_overlay.move_history.add_item(Match.move_history[-1])

func exit():
	previous_state.player.camera_yaw = 180
	next_state.player.camera_object.make_current()
	if previous_state.player.camera_yaw != initial_rotation_degree:
		previous_state.player.camera_yaw = initial_rotation_degree
	camera_rotation = 0
	can_proceed = false
	Match.time_turn_ended = 0
	Match.time_elapsed_since_turn_ended = 0
	Match.board.board_base.material_override.albedo_color = Player.current.color
	#print_rich("[b][color=brown]Exited[/color]: [/b]",name)

func update(_delta:float):
	Match.time_elapsed_since_turn_ended = (
			Time.get_ticks_msec()
			- Match.time_turn_ended
			- Match.TURN_TRANSITION_DELAY_MSEC
			)

	var lerp_weight: float = (
			Match.time_elapsed_since_turn_ended
			* Match.TURN_TRANSITION_SPEED
			)

	if Match.time_elapsed_since_turn_ended > 0:
		can_proceed = true

	if can_proceed and Match.time_elapsed_since_turn_ended * Match.TURN_TRANSITION_SPEED <= 1:
		camera_rotation += 180 * Match.TURN_TRANSITION_SPEED * _delta * 1000
		previous_state.player.camera_yaw = camera_rotation + initial_rotation_degree
		Match.board.board_base.material_override.albedo_color = Player.previous.color.lerp(Player.current.color,lerp_weight)

	if Match.time_elapsed_since_turn_ended * Match.TURN_TRANSITION_SPEED > 1:
		transitioned.emit(self,next_state.name)

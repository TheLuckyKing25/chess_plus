class_name PlayerTurn
extends State

@export var player: Player
@export var board: BoardObject
@export var next_state: State

func enter():
	print_debug("enter ", name)
	board.turn_changed.connect(Callable(self,"on_turn_changed"))
	if Match.is_timed:
		player.timer.start_timer()

func exit():
	print_debug("exit ", name)
	board.turn_changed.disconnect(Callable(self,"on_turn_changed"))
	if Match.is_timed:
		player.timer.stop_timer()
		player.timer.increase_by_increment()

func update(_delta: float):
	if Match.is_timed:
		player.timer._update_timer_ui()

func on_turn_changed():
	transitioned.emit(self,next_state.name)

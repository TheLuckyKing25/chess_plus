class_name StateMachineState
extends State

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func enter() -> void:
	print_rich("[b][color=web_green]Entered[/color]: [/b]",name)
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(Callable(self,"on_child_transition"))

	if initial_state:
		initial_state.enter()
		current_state = initial_state

func exit() -> void:
	current_state.exit()
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.disconnect(Callable(self,"on_child_transition"))
	print_rich("[b][color=brown]Exited[/color]: [/b]",name)

func update(_delta: float) -> void:
	if current_state:
		current_state.update(_delta)

func physics_update(_delta: float) -> void:
	if current_state:
		current_state.physics_update(_delta)

func input(event) -> void:
	if current_state:
		current_state.input(event)

func on_child_transition(state:State, new_state_name:String):
	if state != current_state:
		return

	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		transitioned.emit(self,new_state_name)
		return

	if current_state:
		current_state.exit()

	new_state.enter()

	current_state = new_state

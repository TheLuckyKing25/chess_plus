# Credit to Bitlytic on Youtube: https://youtu.be/ow_Lum-Agbs?si=6jL0ZSBThzB-BUz7
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

## Prepares the states dictionary and sets the current_state
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(Callable(self,"on_child_transition"))

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## This function registers an input and passes it to the current state.
## Prevents other states from trying to process inputs when they are not the current state.
func _input(event) -> void:
	if current_state:
		current_state.input(event)


func on_child_transition(state:State, new_state_name:String):
	if state != current_state:
		return

	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return

	if current_state:
		current_state.exit()

	new_state.enter()

	current_state = new_state

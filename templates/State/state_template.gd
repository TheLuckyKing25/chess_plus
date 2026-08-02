# meta-name: Empty Template
# meta-default: true
extends State


## When this state is entered
func enter():
	pass


## When this state is exited
func exit():
	pass


## Perform updates each frame
func update(_delta:float):
	pass


## Perform physics updates each frame
func physics_update(_delta:float):
	pass


## Register inputs while in this state.
func input(event) -> void:
	pass

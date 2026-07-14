class_name MovementComponent
extends Node

@export var base_movement: AbstractMovement


var movement: AbstractMovement


#func change_facing_direction_base_movement(new_north: Constants.Direction):
	#base_movement.set_facing_direction(new_north as int)



func reset_movement():
	movement = base_movement.duplicate_deep()

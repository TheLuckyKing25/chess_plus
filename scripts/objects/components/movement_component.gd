class_name MovementComponent
extends Node


@export var base_movement: AbstractMovement


var movement: AbstractMovement


func reset_movement():
	movement = base_movement.duplicate_deep()

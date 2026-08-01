class_name MovementComponent
extends Node


signal base_movement_changed


@export var base_movement: Movement:
	set(value):
		base_movement_changed.emit()
		base_movement = value


var movement: Movement


func reset_movement():
	movement = base_movement.duplicate_deep()

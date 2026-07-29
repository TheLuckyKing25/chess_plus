class_name MovementComponent
extends Node


@export var base_movement: Movement


var movement: Movement


func _ready():
	pass


func reset_movement():
	movement = base_movement.duplicate_deep()

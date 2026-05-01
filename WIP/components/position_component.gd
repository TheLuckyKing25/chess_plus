class_name PositionComponent
extends Node

signal position_changed()

var position_vector: Vector2i

func change_position(vector: Vector2i):
	position_vector = vector
	position_changed.emit()

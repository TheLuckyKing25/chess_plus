# Credit to Bitlytic on Youtube: https://youtu.be/ow_Lum-Agbs?si=6jL0ZSBThzB-BUz7
class_name State
extends Node

## Emitted when state transitions to another state
signal transitioned()

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

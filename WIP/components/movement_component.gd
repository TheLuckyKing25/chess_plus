class_name MovementComponent
extends Node

# original unmodified movement
var base_movement: Movement

# movement acounting for player parity and piece modifiers
var current_movement: Movement

# movement converted to a tree of vectors
var current_movement_vector_tree

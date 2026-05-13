## The basic definition of a piece
## this does not change throughout the course of a game.
class_name PieceType extends Resource

## The name of the PieceType.
@export var name:String = "Placeholder":
	set(value):
		name = value
		resource_name = value + " Type"

## The character used to identify the PieceType in algebraic chess notation.
@export var algebraic_notation: String = "_"

## The mesh used for the 3D object of this PieceType.
@export var object_mesh: Mesh

## Allows this PieceType to be promoted.
@export var can_promote:= false

## Allows this PieceType to be a promotion option for promoting pieces.
@export var promotion_option:= false

## Movement initially assigned to pieces of this PieceType.
@export var base_movement: AbstractMovement

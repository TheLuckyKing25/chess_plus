## The basic definition of a piece
@tool
class_name PieceType extends Resource

## The name of the PieceType.
@export var name:String = "Placeholder":
	set(value):
		name = value
		resource_name = value + " Data"

## The character used to identify the PieceType in algebraic chess notation.
@export var algebraic_notation: String = "_"

## The mesh used for the 3D object of this PieceType.
@export var object_mesh: Mesh = null

## Allows this PieceType to be promoted.
@export var can_promote:= false

## Allows this PieceType to be an option for promoting pieces to be promoted to.
@export var promotion_option:= false

## Movement initially assigned to pieces of this PieceType.
@export var movement: AbstractMovement

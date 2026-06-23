## The basic definition of a piece
## this does not change throughout the course of a game.
class_name PieceConfig extends Resource

signal base_movement_changed

## The mesh used for the 3D object of this PieceConfig.
@export var object_mesh: Mesh


@export var icon_light: Texture2D


@export var icon_dark: Texture2D

## The name of the PieceConfig.
@export var name:String = "Placeholder":
	set(value):
		name = value
		resource_name = value + " Type"


## The character used to identify the PieceConfig in algebraic chess notation.
@export var algebraic_notation: String = "_"


## Movement initially assigned to pieces of this PieceConfig.
@export var base_movement: AbstractMovement:
	set(value):
		base_movement = value.duplicate(true)
		base_movement_changed.emit()


@export var rules: Array[PieceRule]

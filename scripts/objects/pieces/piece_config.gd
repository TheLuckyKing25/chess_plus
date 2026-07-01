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
	set = _name_setter


## The character used to identify the PieceConfig in algebraic chess notation.
@export var algebraic_notation: String = "_"


## Movement initially assigned to pieces of this PieceConfig.
@export var base_movement: AbstractMovement:
	set = _base_movement_setter


@export var rules: Array[PieceRule]


#region Getter/Setters
func _name_setter(value: String) -> void:
	name = value
	resource_name = value + " Type"


func _base_movement_setter(value:AbstractMovement) -> void:
	base_movement = value.duplicate(true)
	base_movement_changed.emit()
#endregion

class_name PieceType
extends Resource

@export var name:String

@export_multiline var description: String

@export var object_mesh: Mesh

## This piece can be promoted.
@export var can_promote: bool

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool

@export var movement: Movement

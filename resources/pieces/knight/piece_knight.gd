class_name PieceKnight
extends Piece

static var name:String = "Knight"

@export var algebraic_notation: String = "N"

@export_multiline var description: String

@export var object_mesh: Mesh = preload("res://resources/pieces/knight/mesh_knight.obj")

## This piece can be promoted.
@export var can_promote: bool = false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = true

func _init(new_player:Player,_movement:Movement = preload("res://resources/pieces/knight/movement_knight.tres")):
	resource_local_to_scene = true
	player = new_player
	movement = _movement

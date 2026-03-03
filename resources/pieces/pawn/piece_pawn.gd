class_name PiecePawn
extends Piece

static var name:String = "Pawn"

@export var algebraic_notation: String = "P"

@export_multiline var description: String

@export var object_mesh: Mesh = preload("res://resources/pieces/pawn/mesh_pawn.obj")

## This piece can be promoted.
@export var can_promote: bool = true

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = false


func _init(new_player:Player,_movement:Movement = preload("res://resources/pieces/pawn/movement_pawn_initial.tres")):
	resource_local_to_scene = true
	player = new_player
	movement = _movement

class_name PieceBishop
extends Piece

static var name:String = "Bishop"

@export var algebraic_notation: String = "B"

@export_multiline var description: String

@export var object_mesh: Mesh = preload("res://resources/pieces/bishop/mesh_bishop.obj")

## This piece can be promoted.
@export var can_promote: bool = false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = true


func _init(new_player:Player,_movement:Movement = preload("res://resources/pieces/bishop/movement_bishop.tres")):
	resource_local_to_scene = true
	player = new_player
	movement = _movement

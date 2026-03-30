class_name TileModifier
extends Resource


signal modifier_activated(radius:int)


## The different times a modifier can be applied.
enum TurnState {
	BEGINNING_OF_TURN = 1,
	BEFORE_LANDING = 2,
	AFTER_LANDING = 3,
	END_OF_TURN = 4,
}


enum ModifierType {
	PROPERTY_COG = 1,
	CONDITION_ICY = 2,
	CONDITION_STICKY = 3,
	PROPERTY_CONVEYER = 4,
	PROPERTY_SPRINGY = 5,
	PROPERTY_WALL = 6,
	PROPERTY_POISON = 7,
	PROPERTY_KINGSFAVOR = 8,
	PROPERTY_GATE = 9,
	PROPERTY_BUTTON = 10,
	PROPERTY_LEVER = 11,
}


@export var name: String


@export var icon: Texture2D


@export var color: Color


@export var flag: ModifierType


## When a modifier is applied.
var modifier_application_time: TurnState


var dropdown_ui: Control


## stops movement from entering the tile
var is_blocking: bool = false


## stops movement from leaving the tile
var is_stopping: bool = false

## forces movement to next tile, if said tile is not blocked.
var is_slippery: bool = false

var can_modify_movement: bool = false

static func apply_modifiers_to_moveset(context, tile, piece, moveset):
	var result = moveset
	for modifier in tile.data.modifier_order:
		result = modifier.modify_movement(context, piece, tile, result)
	return result


func _create_dropdown_ui():
	pass


func modify_moves(board, piece, tile, moves):
	return moves


func modify_movement(movement: Movement):
	return


func modify_threats(board, piece, tile, threats):
	return threats


func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	pass


func on_turn_end(board,tile) -> void:
	pass


func blocks_movement(board, piece, tile) -> bool:
	return false


func blocks_passage(context, piece, tile, movement) -> bool:
	return false

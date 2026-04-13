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
	PROPERTY_PROMOTE = 8,
	PROPERTY_GATE = 9,
	PROPERTY_BUTTON = 10,
	PROPERTY_LEVER = 11,
	PROPERTY_SMOKEY = 12,
	PROPERTY_PRISM = 13,
}


@export var name: String


@export var icon: Texture2D


@export var color: Color


@export var flag: ModifierType

@export var components: Dictionary

## When a modifier is applied.
var modifier_application_time: TurnState

var dropdown_ui: Control

## stops movement from entering the tile
var is_blocking: bool = false
## stops movement from leaving the tile
var is_stopping: bool = false
## forces movement to next tile, if said tile is not blocked.
var is_slippery: bool = false

## Modifier forces a piece to a tile, preventing it from landing of the tile with this modifier
var is_forcing_next_tile: bool = false


## changes the piece's movement
var can_modify_movement: bool = false

## force piece to move to a different tile
var can_force_movement: bool = false


static func apply_modifiers_to_moveset(context, tile, piece, moveset):
	var result = moveset
	for modifier in tile.data.modifier_order:
		result = modifier.modify_movement(context, piece, tile, result)
	return result

func modifier_strategy(current_move: CustomTreeNode):
	pass

func create_dropdown_ui():
	dropdown_ui = VBoxContainer.new()
	dropdown_ui.alignment = BoxContainer.ALIGNMENT_CENTER
	dropdown_ui.add_theme_constant_override("separation", 10)
	for component in components.values():
		dropdown_ui.add_child(component.create_setting())



func modify_moves(piece, tile, moves):
	return moves


func modify_movement(movement: Movement):
	return


func modify_threats(piece, tile, threats):
	return threats


func on_piece_enter(piece, from_tile, to_tile) -> void:
	pass


func on_turn_end(tile) -> void:
	pass


func blocks_movement(piece, tile) -> bool:
	return false


func blocks_passage(context, piece, tile, movement) -> bool:
	return false

class_name PieceData
extends Resource

const THREATENED_COLOR:= Color(0.9, 0, 0, 1)
const CHECKING_COLOR:= Color(0.9, 0.9, 0)
const SELECT_COLOR:= Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR:= Color(0.9, 0, 0, 1)
const CASTLING_COLOR:= Color(1,1,1,1)

var player: Player:
	set(new_player):
		player = new_player
		if player and movement:
			movement.set_direction_parity(player.direction_parity)

@export var name:String = "NULL"

@export var algebraic_notation: String = ""

@export_multiline var description: String

@export var object_mesh: Mesh = null

## This piece can be promoted.
@export var can_promote:= false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option:= false


@export var movement: Movement:
	set(new_movement):
		movement = new_movement.get_duplicate()
		if player:
			movement.set_direction_parity(player.direction_parity)

var piece_object_node: PieceObject


# Poison Tile variables
var is_poisoned: bool = false
var poison_turn_applied: int = -1
var poison_duration: int = -1


var index: int = -1


var is_selected: bool = false:
	set(new_state):
		is_selected = new_state
		emit_changed()


var is_threatened: bool = false:
	set(new_state):
		is_threatened = new_state
		emit_changed()


var is_captured: bool = false:
	set(new_state):
		is_captured = new_state
		emit_changed()


var is_checked: bool = false:
	set(new_state):
		is_checked = new_state
		emit_changed()

var is_castling: bool = false:
	set(new_state):
		is_castling = new_state
		emit_changed()


var has_moved: bool = false:
	set(new_state):
		has_moved = new_state
		emit_changed()

class_name PieceStats
extends Resource

const THREATENED_COLOR = Color(0.9, 0, 0, 1)
const CHECKING_COLOR = Color(0.9, 0.9, 0)
const SELECT_COLOR = Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR = Color(0.9, 0, 0, 1)
const SPECIAL_COLOR = Color(1,1,1,1)


@export var type: PieceType

@export var player: Player:
	set(owner):
		player = owner
		match owner.name:
			"Player_One":
				parity = 1 
				direction_parity = 0
			"Player_Two":
				parity = -1 
				direction_parity = 4


## determines which direction to face the piece
var parity: int

## Used to rotate the movement of the piece
var direction_parity: int


var movement: Movement:
	set(new_movement):
		movement = new_movement.get_duplicate()
		movement.set_direction_parity(direction_parity)
		

@export_group("Piece States")
@export var is_selected: bool = false:
	set(new_state):
		is_selected = new_state
		emit_changed()

@export var is_threatened: bool = false:
	set(new_state):
		is_threatened = new_state
		emit_changed()

@export var is_captured: bool = false:
	set(new_state):
		is_captured = new_state
		emit_changed()

@export var is_checked: bool = false:
	set(new_state):
		is_checked = new_state
		emit_changed()

@export var is_checking: bool = false:
	set(new_state):
		is_checking = new_state
		emit_changed()

@export var is_special: bool = false:
	set(new_state):
		is_special = new_state
		emit_changed()

var has_moved: bool = false


func _init(
		piece_type: PieceType,
		new_player:Player
	):
	resource_local_to_scene = true
	type = piece_type
	player = new_player

	movement = type.movement
	

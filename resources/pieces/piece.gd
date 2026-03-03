class_name Piece
extends Resource

signal moved(state:bool)

static var selected: Piece = null
static var en_passant: Piece = null


const THREATENED_COLOR = Color(0.9, 0, 0, 1)
const CHECKING_COLOR = Color(0.9, 0.9, 0)
const SELECT_COLOR = Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR = Color(0.9, 0, 0, 1)
const SPECIAL_COLOR = Color(1,1,1,1)

var name:String = "NULL"

@export var algebraic_notation: String = ""

@export_multiline var description: String

@export var object_mesh: Mesh = null

## This piece can be promoted.
@export var can_promote: bool = false

## Allow this piecetype to be an option for promoting pieces to be promoted to.
@export var promotion_option: bool = false

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

var index: int = -1

var controller: PieceController


var movement: Movement:
	set(new_movement):
		movement = new_movement.get_duplicate()
		movement.set_direction_parity(direction_parity)


var is_selected: bool = false:
	set(new_state):
		is_selected = new_state
		apply_state()


var is_threatened: bool = false:
	set(new_state):
		is_threatened = new_state
		apply_state()


var is_captured: bool = false:
	set(new_state):
		is_captured = new_state
		apply_state()


var is_checked: bool = false:
	set(new_state):
		is_checked = new_state
		apply_state()


var is_checking: bool = false:
	set(new_state):
		is_checking = new_state
		apply_state()


var is_special: bool = false:
	set(new_state):
		is_special = new_state
		apply_state()


var has_moved: bool = false:
	set(new_state):
		_moved(new_state)
		has_moved = new_state

func _moved(state:bool):
	if state:
		controller.add_to_group("has_moved")
	else:
		controller.remove_from_group("has_moved")

func apply_state():
	if is_captured:
		controller._captured()
	elif is_special:
		controller.outline_material.albedo_color = SPECIAL_COLOR
	elif is_checking:
		controller.outline_material.albedo_color = CHECKING_COLOR
	elif is_threatened:
		controller.outline_material.albedo_color = THREATENED_COLOR
	elif is_selected:
		controller.outline_material.albedo_color = SELECT_COLOR
	elif is_checked:
		controller.outline_material.albedo_color = CHECKED_COLOR
	else:
		controller.outline_material.albedo_color = Color(0,0,0,0)


func _ready() -> void:
	controller.add_to_group(name)
	controller._set_mesh(object_mesh)
	
	controller.piece_material.albedo_color = player.color
	controller.add_to_group(player.name)
	match player.name:
		"Player_One": 
			controller.remove_from_group("Player_Two")
			controller.rotate_y(PI)
		"Player_Two": 
			controller.remove_from_group("Player_One")

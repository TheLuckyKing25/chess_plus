class_name PieceData
extends Resource

const THREATENED_COLOR:= Color(0.9, 0, 0, 1)
const CHECKING_COLOR:= Color(0.9, 0.9, 0)
const SELECT_COLOR:= Color(0, 0.9, 0.9, 1)
const CHECKED_COLOR:= Color(0.9, 0, 0, 1)
const CASTLING_COLOR:= Color(1,1,1,1)


@export var name:String = "NULL"
@export var algebraic_notation: String = ""
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

var player: Player:
	set(new_player):
		player = new_player
		if player and movement:
			movement.set_direction_parity(player.direction_parity)

var piece_object_node: PieceObject


# Poison Tile variables
var is_poisoned: bool = false
var poison_turn_applied: int = -1
var poison_duration: int = -1


var index: int = -1


var flag: Dictionary[String, FlagComponent] = {
	"is_selected": FlagComponent.new(),
	"is_threatened": FlagComponent.new(),
	"is_checked": FlagComponent.new(),
	"is_castling": FlagComponent.new(),
	"is_captured":FlagComponent.new(),
	"has_moved": FlagComponent.new(),
}

func connect_flag_components(function:Callable):
	for component in flag.keys():
		flag[component].changed.connect(function)

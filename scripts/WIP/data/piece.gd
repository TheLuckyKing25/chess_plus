class_name Piece extends Resource

@export var base_type: PieceType


var player_owner: Player


var current_movement: Movement


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

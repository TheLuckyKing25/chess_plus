@tool
class_name Piece extends Resource

@export var base_type: PieceType:
	set(value):
		base_type = value
		resource_name = value.name


var player_owner: Player


var current_movement: AbstractMovement


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


static func new_piece(piece_type: PieceType, max_move_distance:int, index:int) -> Piece:
	var new_piece: Piece = Piece.new()
	var new_piece_data: PieceType = piece_type.duplicate(true)

	new_piece.base_type = new_piece_data
	new_piece.current_movement = new_piece_data.movement.get_duplicate()
	new_piece.current_movement.set_max_distance(max_move_distance)
	new_piece.index = index

	return new_piece

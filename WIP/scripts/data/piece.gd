@tool
class_name Piece extends Resource

@export var base_type: PieceType:
	set(value):
		base_type = value
		resource_name = value.name


var name: String:
	get:
		if base_type != null:
			return base_type.name
		else:
			printerr("Name Not Found")
			return ""

var base_movement: AbstractMovement:
	get:
		if base_type:
			return base_type.movement
		else:
			printerr("Movement Not Found")
			return

#var player_owner: Player
@export var player_owner: String:
	set(value):
		if base_type:
			current_movement = base_type.movement.get_duplicate()
			if value == "black":
				current_movement.set_direction_parity(4)
		player_owner = value


@export var current_movement: AbstractMovement:
	get:
		return current_movement.get_duplicate()


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

func assign_player(player:String, dictionary: Dictionary):
	player_owner = player
	if dictionary.has(name):
		dictionary[name].append(self)
	else:
		dictionary[name] = [self]

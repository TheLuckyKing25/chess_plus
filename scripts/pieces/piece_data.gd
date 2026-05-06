## Contains the data of a piece
## this data can change throughout a game.
## this is separate from the 3D piece.
class_name PieceData
extends Resource

signal type_changed(type:PieceType)
signal player_changed()

@export var type: PieceType:
	set(value):
		type_changed.emit()
		type = value


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


## Poison Tile variables
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

static func new_piece(piece_type: PieceType, max_move_distance:int, index:int) -> PieceData:
	var new_piece: PieceData = PieceData.new()
	var new_piece_data: PieceType = piece_type.duplicate(true)

	new_piece.type = new_piece_data
	new_piece.index = index
	new_piece.resource_name = new_piece.type.name

	return new_piece

func connect_flag_components(function:Callable):
	for component in flag.keys():
		flag[component].changed.connect(function)

func assign_player(player:String):
	self.player = GameController.player[player.to_lower()]

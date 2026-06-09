## Contains the data of a piece
## this data can change throughout a game.
## this is separate from the 3D piece.
class_name PieceData
extends Resource

signal type_changed(new_type:PieceType)
signal player_changed(new_player:PlayerData)

@export var type: PieceType:
	set(value):
		type_changed.emit(value)
		_adjusted_movement = value.base_movement.get_duplicate()
		type = value


# movement that accounts for the player the piece belongs to.
# used to reset current_movement
var _adjusted_movement: AbstractMovement:
	set(value):
		_adjusted_movement = value
		_apply_direction_parity_to_movement()
	get:
		return _adjusted_movement


# movement used by modifiers
var current_movement: AbstractMovement



var player: PlayerData:
	set(new_player):
		player_changed.emit(new_player)
		player = new_player
		_apply_direction_parity_to_movement()


var rank: int


var file: int


var index: int


var board_position: Vector2i:
	set(value):
		rank = value.x
		file = value.y
	get():
		return Vector2i(rank,file)


var assigned_object: PieceObject:
	set(value):
		assigned_object = value


func _init():
	player_changed.connect(_on_player_changed)


static func new_piece(piece_type: PieceType, max_move_distance:int, new_index:int) -> PieceData:
	var piece: PieceData = PieceData.new()
	var new_piece_data: PieceType = piece_type.duplicate(true)

	piece.type = new_piece_data
	piece.type.base_movement.set_max_distance(GameData.max_board_length)
	piece.index = new_index
	piece.resource_name = piece.type.name

	return piece


func assign_player(new_player:String):
	player = GameData.players[new_player.to_lower()].data


func _apply_direction_parity_to_movement():
	if player and _adjusted_movement:
		_adjusted_movement.set_direction_parity(player.direction_parity)
		current_movement = _adjusted_movement.get_duplicate()


func _on_player_changed(player_data: PlayerData):
	if player:
		player.pieces.get(type.name.to_lower()).erase(self)
	if player_data:
		player_data.pieces.get_or_add(type.name.to_lower(),[]).append(self)

func reset_current_movement():
	current_movement = _adjusted_movement.get_duplicate()




## Poison Tile variables
var is_poisoned: bool = false
var poison_turn_applied: int = -1
var poison_duration: int = -1

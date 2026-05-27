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
		type = value


var player: PlayerData:
	set(new_player):
		player_changed.emit(new_player)
		player = new_player


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


static func new_piece(piece_type: PieceType, max_move_distance:int, index:int) -> PieceData:
	var new_piece: PieceData = PieceData.new()
	var new_piece_data: PieceType = piece_type.duplicate(true)

	new_piece.type = new_piece_data
	new_piece.index = index
	new_piece.resource_name = new_piece.type.name

	return new_piece


func assign_player(player:String):
	self.player = GameData.player[player.to_lower()].data


func _on_player_changed(player_data: PlayerData):
	if player:
		player.pieces.get(type.name.to_lower()).erase(self)
	if player_data:
		player_data.pieces.get_or_add(type.name.to_lower(),[]).append(self)


## Poison Tile variables
var is_poisoned: bool = false
var poison_turn_applied: int = -1
var poison_duration: int = -1

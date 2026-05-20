## Contains the data of a piece
## this data can change throughout a game.
## this is separate from the 3D piece.
class_name PieceData
extends Resource

signal type_changed(new_type:PieceType)
signal player_changed(new_player:Player)

@export var type: PieceType:
	set(value):
		type_changed.emit(value)
		type = value


#@export var movement: Movement#:
	#set(new_movement):
		#movement = new_movement.get_duplicate()
		#if player:
			#movement.set_direction_parity(player.direction_parity)


var player: Player:
	set(new_player):
		player_changed.emit(new_player)
		player = new_player
		#if player and movement:
			#movement.set_direction_parity(player.direction_parity)








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


static func new_piece(piece_type: PieceType, max_move_distance:int, index:int) -> PieceData:
	var new_piece: PieceData = PieceData.new()
	var new_piece_data: PieceType = piece_type.duplicate(true)

	new_piece.type = new_piece_data
	new_piece.index = index
	new_piece.resource_name = new_piece.type.name

	return new_piece


func assign_player(player:String):
	self.player = GameData.player[player.to_lower()]




## Poison Tile variables
var is_poisoned: bool = false
var poison_turn_applied: int = -1
var poison_duration: int = -1

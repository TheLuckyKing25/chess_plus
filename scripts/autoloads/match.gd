extends Node

signal game_state_changed(game_state: int)

enum GameState {
	BOARD_CUSTOMIZATION,
	GAMEPLAY,
}

var	network_invite_info: Dictionary

var board: BoardObject


var current_game_state: GameState = GameState.BOARD_CUSTOMIZATION:
	set(new_game_state):
		game_state_changed.emit(new_game_state)
		current_game_state = new_game_state


# move history
var move_history:Array


var time_turn_ended:int = 0
var time_elapsed_since_turn_ended:int = 0


var turn_num: int = 0

var game_overlay: Node

var is_board_generated: bool = false
var is_timed: bool = false
var end_turn_modifier_moved: bool = false

var is_promotion_occuring: bool = false


var promotion_menu_list: Array = [
	"Bishop",
	"Knight",
	"Rook",
	"Queen"
	]


var players: Dictionary[String,Player] = {}
var tiles:Dictionary[TileObject,TileObject] = {}
var pieces: Dictionary[PieceObject, PieceObject] = {}


func add_tile(tile_object:TileObject):
	tiles[tile_object] = tile_object.data


func remove_tile(tile_object:TileObject):
	tiles.erase(tile_object)


func add_piece(piece_object:PieceObject):
	pieces[piece_object] = piece_object.data


func remove_piece(piece_object:PieceObject):
	tiles.erase(piece_object)


func get_opponent_of(player: Player) -> Player:
	if player == GameData.players.white:
		return GameData.players.black
	elif player == GameData.players.black:
		return GameData.players.white
	else:
		return null


func get_board_index(rank:int,file:int) -> int:
	return (file) + ((rank) * board.data.file_count)


func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/board.data.file_count, index%board.data.file_count)


func is_my_turn() -> bool:
	#var current_player_index: int = 0 if Player.current == GameData.players.white else 1
	return 1 #NetworkManager.is_my_turn(current_player_index)

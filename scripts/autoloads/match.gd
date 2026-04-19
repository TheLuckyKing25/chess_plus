extends Node

signal game_state_changed(game_state: int)

const CAMERA_ROTATION_SPEED:int = 5
const TURN_TRANSITION_DELAY_MSEC:int = 500 # time to wait before starting transition
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC

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
var move_history:MoveList


var time_turn_ended:int = 0
var time_elapsed_since_turn_ended:int = 0


var turn_num: int = 0


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
var tiles:Dictionary[TileObject,TileDataChess] = {}
var pieces: Dictionary[PieceObject, PieceData] = {}


func add_tile(tile_object:TileObject):
	tiles[tile_object] = tile_object.data


func remove_tile(tile_object:TileObject):
	tiles.erase(tile_object)


func add_piece(piece_object:PieceObject):
	pieces[piece_object] = piece_object.data


func remove_piece(piece_object:PieceObject):
	tiles.erase(piece_object)


func get_opponent_of(player: Player) -> Player:
	if player == Match.players.white:
		return Match.players.black
	elif player == Match.players.black:
		return Match.players.white
	else:
		return null


func get_board_index(rank:int,file:int) -> int:
	return (file) + ((rank) * board.data.file_count)


func get_board_position(index: int) -> Vector2i:
	return Vector2i(index/board.data.file_count, index%board.data.file_count)

func select_tile(tile: TileObject) -> void:
	TileObject.selected = tile
	PieceObject.selected = tile.occupant
	TileObject.selected.change("is_selected",true)
	board.show_selected_piece_movement()


func unselect_tile() -> void:
	TileObject.selected.change("is_selected",false)
	TileObject.selected = null
	PieceObject.selected = null
	get_tree().call_group("Tile","clear_flags")

func is_my_turn() -> bool:
	var current_player_index: int = 0 if Player.current == Match.players.white else 1
	return NetworkManager.is_my_turn(current_player_index)

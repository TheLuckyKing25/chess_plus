# GameData Autoload
# holds information that is kept between board states.
extends Node


var match_settings: MatchConfig = MatchConfig.new()


var max_board_length: int = maxi(match_settings.board_size.rank,match_settings.board_size.file)


var players: Dictionary[String, Player] = {}


var active_board_state: BoardData


var rules: Dictionary = {

}


func _ready() -> void:
	if get_child_count() != 0:
		active_board_state = BoardData.create_board(8,8)


func opponent(player: PlayerData):
	return players.values().filter(
			func(value): return value != player.assigned_object
		)[0]

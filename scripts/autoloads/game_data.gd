# GameData Autoload
# holds information that must be kept between board states.

extends Node

var match_settings: MatchSettings = MatchSettings.new()

var player: Dictionary[String, Player] = {}


var active_board_state: BoardData


func _ready() -> void:
	if get_child_count() != 0:
		active_board_state = BoardData.create_board(8,8)


class ItemState extends RefCounted:
	signal changed

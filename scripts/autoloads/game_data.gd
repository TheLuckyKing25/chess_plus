# GameData Autoload
# holds information that is kept between board states.
extends Node


var match_settings: MatchConfig = MatchConfig.new()


var max_board_length: int = maxi(match_settings.board_size.get("rank"),match_settings.board_size.get("file"))


#var active_board_state: BoardObject


var rules: Dictionary = {

}


#func _ready() -> void:
	#if get_child_count() != 0:
		#active_board_state = BoardObject.new(8,8)

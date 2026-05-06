# GameController Autoload
# holds information that must be kept between board states.
# applies a board state to the 3D Board
extends Node

var match_settings: MatchSettings = MatchSettings.new()


var player: Dictionary[String,Player] = {}


var selected:Dictionary = {
	"piece": null,
	"tile": null,
	}


var active_board_state: BoardData


@export var controller_3D:Node3D


func _ready() -> void:
	if get_child_count() == 0:
		return
	_find_player_nodes()
	active_board_state = BoardData.create_board(8,8)


func _find_player_nodes():
	for child in get_children():
		if child is Player:
			player[child.name.to_lower()] = child
	if player.keys().is_empty():
		printerr("No player nodes found. Player dictionary is empty.")


class ItemState extends RefCounted:
	signal changed

class_name PlayerComponent
extends Node


signal player_to_move_changed(new_player: Player)


static var player_dictionary: Dictionary = {}


var player_turn: int = 0


@export var player_to_move: Player:
	set(value):
		player_to_move_changed.emit(value)
		player_to_move = value


var num_of_players: int


func _ready() -> void:
	var children: Array = get_children()
	num_of_players = children.size()
	for child:Player in children:
		player_dictionary.set(child.player_name.to_lower(),child)
	Debug.Printer.print_pretty(player_dictionary)


static func opponent(player: Player):
	var filter: Callable = func(value): return value != player
	return player_dictionary.values().filter(filter)[0]


func next_turn():
	player_turn += 1
	wrap(player_turn, 0, player_dictionary.keys().size())

class_name PlayerComponent
extends Node


signal player_to_move_changed(new_player: Player)


var player_dictionary: Dictionary = {}


var player_turn: int = 0


@export var player_to_move: Player:
	set(value):
		player_to_move_changed.emit(value)
		player_to_move = value


func _ready() -> void:
	var children: Array = get_children()
	for child:Player in children:
		player_dictionary.set(child.player_name.to_lower(),child)
	DebugPrinter.print_pretty(player_dictionary)


func opponent(player: Player):
	var filter: Callable = func(value): return value != player
	return player_dictionary.values().filter(filter)[0]


func next_turn():
	player_turn += 1
	wrap(player_turn, 0, player_dictionary.keys().size())

class_name PlayerComponent
extends Node


var player_dictionary: Dictionary = {}


func _ready() -> void:
	var children: Array = get_children()
	for child:Player in children:
		player_dictionary.set(child.player_name.to_lower(),child)
	DebugPrinter.print_pretty(player_dictionary)

class_name PlayerOwnershipComponent
extends Node


signal player_changed(new_player:Player)


@export var player: Player


func set_player(new_player:Player):
	player_changed.emit(new_player)
	if is_instance_valid(player):
		get_parent().remove_from_group(player.group_name)
	if is_instance_valid(new_player):
		get_parent().add_to_group(new_player.group_name)

	player = new_player

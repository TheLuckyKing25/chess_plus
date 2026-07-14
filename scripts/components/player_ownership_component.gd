class_name PlayerOwnershipComponent
extends Node


signal player_changed(new_player:Player)


@export var player: Player:
	set = _player_setter


func _player_setter(new_player:Player):
	player_changed.emit(new_player)

	if is_instance_valid(player):
		get_parent().remove_from_group("Player_" + player.name)
	if is_instance_valid(new_player):
		get_parent().add_to_group("Player_" + new_player.name)

	player = new_player

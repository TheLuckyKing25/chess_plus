class_name WaitState
extends UIState

@export var previous_state:State

func enter():
	print_rich("[b][color=green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	Match.network_invite_info = NetworkManager.host_game()
	if Match.network_invite_info.is_empty():
		return

	NetworkManager.connected_to_game.connect(Callable(self,"on_connection"))

	add_child(instantiated_scene)
	instantiated_scene.set_ip_label(Match.network_invite_info["ip"])
	instantiated_scene.set_invite_code_label(Match.network_invite_info["code"])


func exit():
	NetworkManager.connected_to_game.disconnect(Callable(self,"on_connection"))

	remove_child(instantiated_scene)
	instantiated_scene.queue_free()

	#print_debug("exit ", name)
	print_rich("[b][color=red]Exited[/color]: [/b]",name)


func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_connection():
	await get_tree().create_timer(1.0).timeout
	NetworkSync.board_setup.rpc(Match.board.data.file_count, Match.board.data.rank_count, Match.board.data.FEN_board_state.FE_notation)
	NetworkSync.tile_modifiers.rpc(Match.board._serialize_tile_modifiers())
	if Match.is_timed:
		NetworkSync.time_control.rpc(TimeControl.max_time_sec, TimeControl.increment_sec)
	NetworkSync.gameplay_start.rpc()

	transitioned.emit(self, "GameOverlayState")


func on_back_pressed():
	transitioned.emit(self, previous_state.name)

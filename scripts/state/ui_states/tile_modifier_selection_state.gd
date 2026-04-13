class_name TileModifierSelectionState
extends UIState

func enter():
	print_rich("[b][color=green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.connect_to_scene_buttons(
			Callable(self,"on_back_pressed"),
			Callable(self,"on_continue_pressed"),
			Callable(self,"on_host_pressed"),
			)

	Match.current_game_state = Match.GameState.BOARD_CUSTOMIZATION
	add_child(instantiated_scene)


func exit():
	instantiated_scene.disconnect_from_scene_buttons(
			Callable(self,"on_back_pressed"),
			Callable(self,"on_continue_pressed"),
			Callable(self,"on_host_pressed"),
			)

	remove_child(instantiated_scene)
	#print_debug("exit ", name)
	print_rich("[b][color=red]Exited[/color]: [/b]",name)

func input(event:InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_back_pressed():
	for child in Match.board.board_base.get_children():
		if child.occupant:
			child.occupant.data.player.remove_piece(child.occupant)
		Match.board.board_base.remove_child(child)
		child.queue_free()

	Match.is_board_generated = false
	Match.board.data.tile_array.clear()
	Match.board.data.piece_array.clear()
	transitioned.emit(self, "MatchCustomizationStateM")


func on_continue_pressed():
	Match.current_game_state = Match.GameState.GAMEPLAY
	Match.game_state_changed.emit(Match.current_game_state)
	get_tree().call_group("Tile","clear_states")
	get_tree().call_group("Tile","remove_from_group","Selected")

	if NetworkManager.is_online:
		NetworkSync.gameplay_start.rpc()

	transitioned.emit(self, "GameOverlayState")


func on_host_pressed():
	transitioned.emit(self, "WaitState")

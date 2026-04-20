extends UIState

func enter():
	print_rich("[b][color=web_green]Entered[/color]: [/b]",name)

	if not instantiated_scene:
		instantiated_scene = scene.instantiate()
		if Match.is_timed:
			instantiated_scene.show_timers()
			Match.players.white.timer.label = instantiated_scene.get_ui_timer_white()
			Match.players.black.timer.label = instantiated_scene.get_ui_timer_black()
		if NetworkManager.is_online:
			await get_tree().create_timer(0.5).timeout
			NetworkSync.board_setup.rpc(Match.board.data.file_count, Match.board.data.rank_count, Match.board.data.FEN_board_state.FE_notation)
			NetworkSync.tile_modifiers.rpc(Match.board._serialize_tile_modifiers())
			if Match.is_timed:
				NetworkSync.time_control.rpc(TimeControl.max_time_sec, TimeControl.increment_sec)
			NetworkSync.gameplay_start.rpc()

	Match.current_game_state = Match.GameState.GAMEPLAY
	add_child(instantiated_scene)

	instantiated_scene.connect_to_pause_button(Callable(self,"on_pause_pressed"))
	instantiated_scene.new_placement_selected.connect(Callable(self,"on_new_placement_selected"))
	Match.board.promotion_verified.connect(Callable(self,"on_promotion_verified"))

	instantiated_scene.horizontal_slider.value_changed.connect(Callable(self, "on_camera_horizontal_offset_changed"))
	instantiated_scene.forward_slider.value_changed.connect(Callable(self, "on_camera_forward_offset_changed"))



func exit():
	instantiated_scene.disconnect_from_pause_button(Callable(self,"on_pause_pressed"))
	instantiated_scene.new_placement_selected.disconnect(Callable(self,"on_new_placement_selected"))

	Match.board.promotion_verified.disconnect(Callable(self,"on_promotion_verified"))
	instantiated_scene.horizontal_slider.value_changed.disconnect(Callable(self, "on_camera_horizontal_offset_changed"))
	instantiated_scene.forward_slider.value_changed.disconnect(Callable(self, "on_camera_forward_offset_changed"))

	remove_child(instantiated_scene)
	print_rich("[b][color=brown]Exited[/color]: [/b]",name)


func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_pause_pressed()


func on_pause_pressed():
	transitioned.emit(self, "PauseMenuState")

func on_new_placement_selected(placement: FEN) -> void:
	Match.board.data.piece_array.clear()
	for tile in Match.board.data.tile_array:
		if tile.occupant:
			var piece: PieceObject = tile.occupant
			tile.occupant = null
			tile.remove_child(piece)
			piece.data.player.remove_piece(piece)
			piece.queue_free()

	Match.board.data.piece_array.resize(Match.board.data.rank_count * Match.board.data.file_count)
	Match.board.load_FEN(placement)

func on_camera_horizontal_offset_changed(value:float):
	Player.current.change_camera_horizontal_offset(value)

func on_camera_forward_offset_changed(value:float):
	Player.current.change_camera_forward_offset(value)

func on_promotion_verified(piece: PieceObject) -> void:
	if piece == null:
		return
	if not piece.data.can_promote:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	instantiated_scene._show_promotion_menu(mouse_pos)
	get_tree().paused = true
	instantiated_scene.promotion_piecetype_selected.connect(Callable(piece,"promote"))
	await piece.promoted
	piece.data.movement.set_max_distance(maxi(Match.board.data.file_count,Match.board.data.rank_count))
	instantiated_scene._hide_promotion_menu()
	instantiated_scene.promotion_piecetype_selected.disconnect(Callable(piece,"promote"))
	get_tree().paused = false

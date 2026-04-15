extends UIState

func enter():
	print_rich("[b][color=green]Entered[/color]: [/b]",name)
	#print_debug("enter ", name)
	if not instantiated_scene:
		instantiated_scene = scene.instantiate()

	instantiated_scene.connect_to_scene_buttons(
		Callable(self,"on_back_pressed"),
		Callable(self,"on_continue_pressed"),
		Callable(self,"on_start_pressed"),
		Callable(self,"on_host_pressed")
	)
	instantiated_scene.board_verified.connect(Callable(self,"on_board_verified"))
	instantiated_scene.time_control_selected.connect(Callable(self,"on_time_control_selection"))
	add_child(instantiated_scene)


func exit():
	instantiated_scene.disconnect_from_scene_buttons(
		Callable(self,"on_back_pressed"),
		Callable(self,"on_continue_pressed"),
		Callable(self,"on_start_pressed"),
		Callable(self,"on_host_pressed")
	)

	instantiated_scene.board_verified.disconnect(Callable(self,"on_board_verified"))
	instantiated_scene.time_control_selected.disconnect(Callable(self,"on_time_control_selection"))

	if not Match.is_board_generated and Match.board.data.FEN_board_state:
		Match.current_game_state = Match.GameState.GAMEPLAY
		Match.board.generate_board()
		Match.board.load_FEN(Match.board.data.FEN_board_state)
		Match.is_board_generated = true
		for tile in get_tree().get_nodes_in_group("Tile"):
			tile.clicked.connect(Callable(Match.board,"_on_tile_clicked"))

	remove_child(instantiated_scene)
	#print_debug("exit ", name)
	print_rich("[b][color=red]Exited[/color]: [/b]",name)

func input(event) -> void:
	if event.is_action_released("ui_cancel"):
		on_back_pressed()

func on_back_pressed():
	transitioned.emit(self, "StartMenuState")

func on_host_pressed():
	transitioned.emit(self, "WaitState")

func on_start_pressed():
	transitioned.emit(self, "GameOverlayState")

func on_continue_pressed():
	transitioned.emit(self, "TileModifierSelectionStateM")

func on_board_verified(rank_num:int,file_num:int,FEN_notation: FEN) -> void:
	Match.board.data.FEN_board_state = FEN_notation
	Match.board.data.rank_count = rank_num
	Match.board.data.file_count = file_num

func on_time_control_selection(time_sec: int, increment_sec: int):
	Match.is_timed = true
	TimeControl.increment_sec = increment_sec
	TimeControl.max_time_sec = time_sec

	Match.players.white.timer.set_timer(time_sec)
	Match.players.black.timer.set_timer(time_sec)

	if NetworkManager.is_online:
		NetworkSync.time_control.rpc(time_sec, increment_sec)

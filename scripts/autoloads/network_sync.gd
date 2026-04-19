extends Node

@rpc("authority", "call_remote", "reliable")
func time_control(time_sec: int, increment_sec: int) -> void:
	Match.is_timed = true
	TimeControl.increment_sec = increment_sec
	TimeControl.max_time_sec = time_sec
	Match.players.white.timer.set_timer(time_sec)
	Match.players.black.timer.set_timer(time_sec)

@rpc("authority", "call_remote", "reliable")
func board_setup(file_count: int, rank_count: int, fen_string: String) -> void:
	if fen_string.is_empty():
		return
	Match.board.data.file_count = file_count
	Match.board.data.rank_count = rank_count
	Match.board.data.FEN_board_state = FEN.new(fen_string)
	Match.board.generate_board()
	Match.board.load_FEN(Match.board.data.FEN_board_state)
	Match.current_game_state = Match.GameState.BOARD_CUSTOMIZATION
	#for tile in get_tree().get_nodes_in_group("Tile"):
		#tile.clicked.connect(Callable(tile, "_on_tile_clicked"))

@rpc("authority", "call_remote", "reliable")
func gameplay_start() -> void:
	Match.current_game_state = Match.GameState.GAMEPLAY
	Match.game_state_changed.emit(Match.current_game_state)

	Match.board.data.legal_moves = MoveList.new(Match.board.data)
	Match.board.data.legal_moves.generate_legal_moves(Player.current)

@rpc("authority", "call_remote", "reliable")
func tile_modifiers(modifier_data: Dictionary) -> void:
	for tile_index in modifier_data.keys():
		var tile: TileObject = Match.board.data.tile_array[tile_index]
		var new_modifier_order: Array[TileModifier] = []
		for entry in modifier_data[tile_index]:
			var modifier: TileModifier = load(entry["script"]).new()
			match modifier.flag:
				TileModifier.ModifierType.CONDITION_ICY:
					modifier.lifetime = entry["lifetime"]
				TileModifier.ModifierType.CONDITION_STICKY:
					modifier.lifetime = entry["lifetime"]
				TileModifier.ModifierType.PROPERTY_BUTTON:
					modifier.radius = entry["radius"]
				TileModifier.ModifierType.PROPERTY_COG:
					modifier.rotation = entry["rotation"]
				TileModifier.ModifierType.PROPERTY_CONVEYER:
					modifier.direction = entry["direction"]
				TileModifier.ModifierType.PROPERTY_GATE:
					modifier.is_active = entry["is_active"]
				TileModifier.ModifierType.PROPERTY_LEVER:
					modifier.radius = entry["radius"]
				TileModifier.ModifierType.PROPERTY_POISON:
					modifier.lifetime = entry["lifetime"]
					modifier.duration = entry["duration"]
				TileModifier.ModifierType.PROPERTY_SMOKEY:
					modifier.is_active = entry["is_active"]
				TileModifier.ModifierType.PROPERTY_SPRINGY:
					modifier.destination = Vector2i(entry["destination_x"], entry["destination_y"])
			new_modifier_order.append(modifier)
		tile.data.modifier_order = new_modifier_order

@rpc("authority", "call_remote", "reliable")
func timer_start(host_timestamp: float) -> void:
	var latency_sec: float = Time.get_unix_time_from_system() - host_timestamp
	Player.current.timer.start_timer()
	Player.current.timer.reduce_by(latency_sec)

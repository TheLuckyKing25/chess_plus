class_name BoardObject
extends Node3D


signal turn_changed()
signal game_state_changed(game_state: int)
signal promotion_verified(piece: PieceObject)


const SMOKE: PackedScene = preload("uid://6mhxpvgl814g")


var _game_overlay: Node


var smokey_overlay: Dictionary = {}
var smokey_tiles: Array[TileObject] = []
var smokey_pieces: Array[PieceObject] = []


var data: BoardData


@onready var board_base = $BoardBase
@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move


func _ready() -> void:
	data = BoardData.new()
	Match.board = self
	Match.board.data = data

	Player.current = Match.players.white
	Player.previous = Match.players.white

	if NetworkManager.is_online:
		NetworkManager.opponent_disconnected.connect(_on_opponent_disconnected)

	if NetworkManager.is_online and multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected_resync)

	if NetworkManager.is_online and not multiplayer.is_server():
		_show_loading_screen()


#region multilplayer
func _show_loading_screen() -> void:
	var wait_layer := CanvasLayer.new()
	wait_layer.layer = 10
	wait_layer.name = "LoadingLayer"
	add_child(wait_layer)
	var loading = preload("uid://v4i5knax4g12").instantiate()
	wait_layer.add_child(loading)


func _hide_loading_screen() -> void:
	var loading_layer = get_node_or_null("LoadingLayer")
	if loading_layer:
		loading_layer.queue_free()

func _on_peer_connected_resync(_id: int) -> void:
	if Match.current_game_state == Match.GameState.GAMEPLAY:
		await get_tree().create_timer(0.5).timeout
		NetworkSync.board_setup.rpc(data.file_count, data.rank_count, data.FEN_board_state.FE_notation)
		await get_tree().create_timer(0.5).timeout
		NetworkSync.tile_modifiers.rpc(_serialize_tile_modifiers())
		NetworkSync.gameplay_start.rpc()


func _on_opponent_disconnected() -> void:
	get_tree().paused = true
	print("Opponent disconnected. Game paused.")


func _serialize_tile_modifiers() -> Dictionary:
	var result: Dictionary = {}
	for tile in data.tile_array:
		if tile.data.modifier_order.is_empty():
			continue
		var modifier_list: Array = []
		for modifier in tile.data.modifier_order:
			var entry: Dictionary = {
				"script": modifier.get_script().resource_path
			}
			match modifier.flag:
				TileModifier.ModifierType.CONDITION_ICY:
					entry["lifetime"] = modifier.lifetime
				TileModifier.ModifierType.CONDITION_STICKY:
					entry["lifetime"] = modifier.lifetime
				TileModifier.ModifierType.PROPERTY_BUTTON:
					entry["radius"] = modifier.radius
				TileModifier.ModifierType.PROPERTY_COG:
					entry["rotation"] = modifier.rotation
				TileModifier.ModifierType.PROPERTY_CONVEYER:
					entry["direction"] = modifier.direction
				TileModifier.ModifierType.PROPERTY_GATE:
					entry["is_active"] = modifier.is_active
				TileModifier.ModifierType.PROPERTY_LEVER:
					entry["radius"] = modifier.radius
				TileModifier.ModifierType.PROPERTY_POISON:
					entry["lifetime"] = modifier.lifetime
					entry["duration"] = modifier.duration
				TileModifier.ModifierType.PROPERTY_SMOKEY:
					entry["is_active"] = modifier.is_active
				TileModifier.ModifierType.PROPERTY_SPRINGY:
					entry["destination_x"] = modifier.destination.x
					entry["destination_y"] = modifier.destination.y
			modifier_list.append(entry)
		result[tile.data.index] = modifier_list
	return result

func submit_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_tile_index: int = -1) -> void:
	_execute_move(from_index, to_index, flags, ep_piece_index, ep_tile_index)
	if NetworkManager.is_online:
		_sync_move.rpc(from_index, to_index, flags, ep_piece_index, ep_tile_index)

@rpc("any_peer", "call_remote", "reliable")
func _sync_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_tile_index: int = -1) -> void:
	_execute_move(from_index, to_index, flags, ep_piece_index, ep_tile_index)

func _execute_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_tile_index: int = -1) -> void:
	var from_tile: TileObject = data.tile_array[from_index]
	var to_tile: TileObject = data.tile_array[to_index]

	TileObject.selected = from_tile
	PieceObject.selected = from_tile.occupant

	if ep_piece_index >= 0 and ep_tile_index >= 0:
		PieceObject.en_passant = data.piece_array[ep_piece_index]
		TileObject.en_passant = data.tile_array[ep_tile_index]
		Player.en_passant = Player.current

	if flags & Move.Outcome.EN_PASSANT:
		_capture_piece(PieceObject.en_passant)
		perform_move(Move.new(from_tile, to_tile, flags))

	elif flags & Move.Outcome.CAPTURING:
		_capture_piece(to_tile.occupant)
		perform_move(Move.new(from_tile, to_tile, flags))

	elif flags & (Move.Outcome.CASTLING_KINGSIDE | Move.Outcome.CASTLING_QUEENSIDE):
		_perform_castling_move(to_tile)

	else:
		perform_move(Move.new(from_tile, to_tile, flags))

	if Match.is_promotion_occuring:
		await to_tile.occupant.promoted
		Match.is_promotion_occuring = false

	next_turn()
#endregion


func generate_board() -> void:
	data.tile_array.resize(data.file_count * data.rank_count)
	data.piece_array.resize(data.file_count * data.rank_count)

	# Change the size of the board base to match the size of the board
	$BoardBase.mesh.size = Vector3(data.file_count+1 ,0.2, data.rank_count+1)

	for tile_num in range(data.rank_count * data.file_count):
		var new_tile:TileObject = TileObject.new_tile(tile_num)
		new_tile.data.board_position = Match.get_board_position(new_tile.data.index)

		data.tile_array[tile_num] = new_tile
		# move tile to its location on the board
		new_tile.translate(Vector3(
				new_tile.data.file-(float(data.file_count)/2)+0.5,
				0.1,
				(float(data.rank_count)/2)-new_tile.data.rank-0.5
			))
		$BoardBase.add_child(new_tile, true)

	data.assign_tile_neighbors()

func load_FEN(FE_notation:FEN) -> void:
	var fen_decoder := FENDecoder.new(FE_notation)
	data.FEN_board_state = FE_notation
	get_tree().call_group("Tile","clear_flags")
	fen_decoder.apply()

	data.legal_moves = MoveList.new(data)
	data.legal_moves.generate_legal_moves(Player.current)

	get_tree().call_group("Tile","clear_check_flag")
	detect_check(Player.current)


func detect_check(player:Player) -> void:
	var player_king: PieceObject = player.pieces["King"][0]
	var player_king_tile: TileObject = data.tile_array[player_king.data.index]

	var opponent_moves: MoveList = MoveList.new(data)
	opponent_moves.generate_pseudo_legal_moves(Match.get_opponent_of(player))

	for move in opponent_moves.moves:
		if (	move.destination_tile.is_occupied
				and move.destination_tile.occupant.is_in_group("King")
				and move.destination_tile.occupant.is_in_group(player.name)
				):
			player_king_tile.change("is_checked",true)
			break


func _set_en_passant(clicked_tile: TileObject) -> void:
	PieceObject.en_passant = PieceObject.selected
	var en_passant_tile_rank = (
			TileObject.selected.data.rank
			+ (clicked_tile.data.rank - TileObject.selected.data.rank)/2
			)
	var en_passant_tile_file = TileObject.selected.data.file
	TileObject.en_passant = data.tile_array[Match.get_board_index(en_passant_tile_rank,en_passant_tile_file)]
	Player.en_passant = Player.current


#region MODIFIER HELPER FUNCTIONS
func _apply_turn_end_modifiers() -> void:
	var max := 16
	var t := 0
	while t < max:
		Match.end_turn_modifier_moved = false
		for tile in data.tile_array:
			for modifier in tile.data.modifier_order:
				modifier.on_turn_end(tile)
		for tile in data.tile_array:
			data.piece_array[tile.data.index] = tile.occupant
		if not Match.end_turn_modifier_moved:
			break
		t += 1


func _update_modifier_lifetimes() -> void:
	for tile in data.tile_array:
		var updated_modifiers: Array[TileModifier] = []
		for modifier in tile.data.modifier_order:
			var lifetime = modifier.get("lifetime")

			if lifetime == null or lifetime == -1:
				updated_modifiers.append(modifier)
				continue

			if lifetime > 0:
				modifier.lifetime -= 1

			if modifier.lifetime != 0:
				updated_modifiers.append(modifier)

		tile.data.modifier_order = updated_modifiers

func _update_poisoned_pieces() -> void:
	for tile in data.tile_array:
		var piece = tile.occupant
		if piece == null:
			continue
		if not piece.data.is_poisoned:
			continue
		if Match.turn_num - piece.data.poison_turn_applied >= piece.data.poison_duration:
			_capture_piece(piece)


func _tile_in_radius(origin_tile, target_tile, radius) -> bool:
	var delta: Vector2i = target_tile.data.board_position - origin_tile.data.board_position
	return max(abs(delta.x), abs(delta.y)) <= radius # return true if within specified radius


func _toggle_gates_in_radius(origin_tile, radius) -> void:
	print("Toggling gates from ", origin_tile.data.board_position, " radius=", radius)
	for tile in data.tile_array:
		if not _tile_in_radius(origin_tile, tile, radius):
			continue

		var changed := false
		for modifier in tile.data.modifier_order:
			if modifier is PropertyGate:
				modifier.is_active = not modifier.is_active
				changed = true

		if changed:
			tile.data.emit_changed()


func _apply_on_piece_pass(move: Move) -> void:
	var piece: PieceObject = move.destination_tile.occupant
	if piece == null:
		return

	var start := move.starting_tile.data.board_position
	var dest := move.destination_tile.data.board_position
	var delta := dest - start

	# Normalize delta or else the movement is strange
	delta.x = sign(delta.x)
	delta.y = sign(delta.y)

	var current_pos := start + delta

	while current_pos != dest:
		if current_pos.x < 0 or current_pos.x >= data.rank_count:
			break
		if current_pos.y < 0 or current_pos.y >= data.file_count:
			break
		var tile := data.tile_array[Match.get_board_index(current_pos.x, current_pos.y)]

		for modifier in tile.data.modifier_order:
			if modifier is PropertyLever:
				modifier.activate(self, tile)

		current_pos += delta

func _get_smokey_tiles(origin_tile: TileObject, smokey: PropertySmokey) -> Array[TileObject]:
	var out: Array[TileObject] = []
	var origin := origin_tile.data.board_position

	var offsets : Array[Vector2i] = []
	if smokey.activated_by_player == Match.players.white:
		offsets = [
			Vector2i(1, 0),
			Vector2i(2, 0),
		]
	elif smokey.activated_by_player == Match.players.black:
		offsets = [
			Vector2i(-1, 0),
			Vector2i(-2, 0),
		]
	else:
		return out

	for offset in offsets:
		var pos : Vector2i = origin + offset

		if pos.x < 0 or pos.x >= data.rank_count:
			continue
		if pos.y < 0 or pos.y >= data.file_count:
			continue

		var tile := data.tile_array[Match.get_board_index(pos.x, pos.y)]
		if tile != null and not out.has(tile):
			out.append(tile)

	return out

func _clear_smokey_visuals() -> void:
	for overlay in smokey_overlay.values():
		if is_instance_valid(overlay):
			overlay.queue_free()
	smokey_overlay.clear()

	for piece in smokey_pieces:
		if is_instance_valid(piece):
			piece.visible = true
	smokey_pieces.clear()
	smokey_tiles.clear()

func _create_smokey_overlay(tile: TileObject) -> void:
	if smokey_overlay.has(tile):
		return

	var overlay = SMOKE.instantiate()
	add_child(overlay)
	overlay.global_position = tile.global_position + Vector3(0, 1.2, 0)
	smokey_overlay[tile] = overlay

func _update_smokey_visuals() -> void:
	_clear_smokey_visuals()

	for tile in data.tile_array:
		for modifier in tile.data.modifier_order:
			if modifier is PropertySmokey and modifier.is_active:
				for affected_tile in _get_smokey_tiles(tile, modifier):
					_create_smokey_overlay(affected_tile)

					if not smokey_tiles.has(affected_tile):
						smokey_tiles.append(affected_tile)

					if affected_tile.occupant != null:
						affected_tile.occupant.visible = false
						if not smokey_pieces.has(affected_tile.occupant):
							smokey_pieces.append(affected_tile.occupant)
#endregion

func _perform_castling_move(castling_tile: TileObject) -> void:
	var middle_file_value: float = (data.file_count/2) - 1
	var castling_rook_index: int
	var destination_index: int

	# kingside castling
	if castling_tile.data.file > middle_file_value:
		castling_rook_index = Match.get_board_index(castling_tile.data.rank,data.file_count-1)
		destination_index = castling_tile.neighbors[Movement.Direction.WEST].data.index
		perform_move(Move.new(TileObject.selected, castling_tile, Move.Outcome.CASTLING_KINGSIDE))

	# queenside castling
	elif castling_tile.data.file < middle_file_value:
		castling_rook_index = Match.get_board_index(castling_tile.data.rank,0)
		destination_index = castling_tile.neighbors[Movement.Direction.EAST].data.index
		perform_move(Move.new(TileObject.selected, castling_tile, Move.Outcome.CASTLING_QUEENSIDE))

	var castling_rook_destination = data.tile_array[destination_index]
	perform_move(Move.new(data.tile_array[castling_rook_index],castling_rook_destination,Move.Outcome.IGNORE))


## Shows the valid tiles the selected piece can move to
func show_selected_piece_movement() -> void:
	var moveset:Movement = PieceObject.selected.data.movement.get_duplicate()
	#moveset = TileModifier.apply_modifiers_to_moveset(self, TileObject.selected, PieceObject.selected, moveset)
	_resolve_branching_movement(PieceObject.selected, moveset, TileObject.selected )


# SAME LOGIC USED IN MoveList RESOURCE.
# IF THE LOGIC IS CHANGED HERE, MAKE SURE TO CHANGE THAT AS WELL
func _resolve_branching_movement(active_piece:PieceObject,moveset: Movement,origin_tile: TileObject) -> void:

	moveset = moveset.get_duplicate()

	for modifier in origin_tile.data.modifier_order:
		if modifier.can_modify_movement:
			modifier.modify_movement(moveset)


	for branch in moveset.branches:
		var current_tile_ptr: TileObject = origin_tile

		branch.purpose = moveset.purpose
		var distance: int = branch.distance
		var can_proceed_with_branch: bool = true
		var has_slid:bool = false

		while distance > 0:
			current_tile_ptr = current_tile_ptr.neighbors[branch.direction]

			if current_tile_ptr == null:
				break # current_tile_ptr does not exist

			for modifier in current_tile_ptr.data.modifier_order:
				if moveset.is_jump:
					break

				if modifier.is_blocking:
					distance = 0
					can_proceed_with_branch = false
					break

				if modifier.is_stopping:
					distance = 1
					moveset.is_branching = false

				if modifier.is_slippery:
					var next_tile = current_tile_ptr.get_next_tile(branch.direction)
					if not next_tile.occupant:
						has_slid = true
						break

				if modifier.can_modify_movement:
					modifier.modify_movement(branch)
					distance = branch.distance

			if has_slid:
				has_slid = false
				continue

			if can_proceed_with_branch == false:
				can_proceed_with_branch = true
				break


			if branch.is_threaten:
				# NORMAL THREATEN LOGIC
				if (	current_tile_ptr.is_occupied
						and active_piece.data.player != current_tile_ptr.occupant.data.player # current_tile_ptr is occupied by opponent piece
						):
					current_tile_ptr.change("is_threatened",true)
					break

				# EN PASSANT LOGIC
				elif ( 	not current_tile_ptr.is_occupied
						and PieceObject.en_passant
						and active_piece.data.player != PieceObject.en_passant.data.player
						and current_tile_ptr == TileObject.en_passant
						):
					TileObject.en_passant.change("is_threatened",true)
					PieceObject.en_passant.data.flag.is_threatened.enabled = true


			if not branch.is_jump:
				# JUMP LOGIC
				if (	current_tile_ptr.is_occupied
						and active_piece != current_tile_ptr.occupant # current_tile_ptr not is occupied by active piece
						):
					break


			if branch.is_move:
				#MOVEMENT LOGIC
				if not current_tile_ptr.is_occupied:
					var possible_move: Array[TileObject] = [data.tile_array[active_piece.data.index], current_tile_ptr]
					if data.legal_moves.contains_move(possible_move):
						current_tile_ptr.data.flag.is_movement.enabled = true
					else:
						current_tile_ptr.data.flag.is_checked_movement.enabled = true

						# King cannot castle through checked tile
						if active_piece.data.name == "King":
							if branch.direction == Movement.Direction.EAST:
								active_piece.data.set_meta("is_castling_kingside_valid", false)
							elif branch.direction == Movement.Direction.WEST:
								active_piece.data.set_meta("is_castling_queenside_valid", false)


			if branch.is_castling:
				var king_tile: TileObject = TileObject.selected

				if (	active_piece.data.flag.has_moved.enabled # if king has moved
						or active_piece.data.flag.is_checked.enabled # if king is in check
						or (	branch.direction == Movement.Direction.EAST
								and not active_piece.data.get_meta("is_castling_kingside_valid"))	# if east tile is checked
						or (	branch.direction == Movement.Direction.WEST
								and not active_piece.data.get_meta("is_castling_queenside_valid")) # if west tile is checked
						):
					break

				# Get rook tile for current castling side
				var rook_tile: TileObject
				if current_tile_ptr.data.board_position > king_tile.data.board_position:
					rook_tile = data.tile_array[Match.get_board_index(king_tile.data.rank,data.file_count-1)]
				elif current_tile_ptr.data.board_position < king_tile.data.board_position:
					rook_tile = data.tile_array[Match.get_board_index(king_tile.data.rank,0)]

				if (	not rook_tile.is_occupied # if no occupant
						or not rook_tile.occupant.is_in_group("Rook") # if occupant is not a rook
						or rook_tile.occupant.data.flag.has_moved.enabled # if rook has moved
						):
					break

				# equation gives either 1 or -1
				var range_increment_direction:int = (
						(rook_tile.data.file - king_tile.data.file)
						/ abs(rook_tile.data.file - king_tile.data.file)
						)

				var is_empty_between_pieces: bool = true
				for tile_file in range(king_tile.data.file + range_increment_direction, rook_tile.data.file, range_increment_direction):
					if data.tile_array[Match.get_board_index(king_tile.data.rank,tile_file)].occupant:
						is_empty_between_pieces = false

				if not is_empty_between_pieces: # tiles between rook and king are occupied
					break

				if data.legal_moves.contains_move([data.tile_array[active_piece.data.index], current_tile_ptr]):
					rook_tile.occupant.data.flag.is_castling.enabled = true
					current_tile_ptr.change("is_castling",true)


			distance -= 1


		if branch.is_branching and distance == 0:
			_resolve_branching_movement(active_piece, branch, current_tile_ptr)


func _capture_piece(piece) -> void:
	piece._captured()
	piece_capture_audio.play()


func perform_move(move: Move):
	get_tree().call_group("Tile","clear_check_flag")
	get_tree().call_group("Tile","clear_flags")
	var piece: PieceObject = move.starting_tile.occupant
	move.starting_tile.occupant = null

	piece.move_to(move.destination_tile)
	piece_move_audio.play()

	if not piece.data.flag.has_moved.enabled:
		piece.moved(true)

	TileModifier.apply_on_piece_enter(move) # used for poison, kings favor, smokey, and button
	_apply_on_piece_pass(move) # used only for lever

	# match occupants in piece_array to their respective tiles in tile_array
	for tile in data.tile_array:
		data.piece_array[tile.data.index] = tile.occupant

	# determine if check or checkmate has occured
	var opponent_moves:= MoveList.new(data)
	opponent_moves.generate_legal_moves(Match.get_opponent_of(Player.current))
	if opponent_moves.moves.is_empty():
		move.outcome_flag.checkmate.enabled = true
		_game_overlay.show_checkmate(Player.current)


	detect_check(Match.get_opponent_of(Player.current))
	if not opponent_moves.moves.is_empty() and Match.get_opponent_of(Player.current).pieces["King"][0].data.flag.is_checked.enabled:
		move.outcome_flag.check.enabled = true

	if piece.data.can_promote and move.destination_tile.data.rank == piece.data.player.promotion_rank:
		move.outcome_flag.promotion.enabled = true
		Match.is_promotion_occuring = true
		promotion_verified.emit(piece)

	if not piece.data.flag.has_moved.enabled:
		piece.moved(true)

	#if AlgebraicNotaion.get_notation(move) != "": # empty string due to castling move
		#if move.outcome_flag.promotion.enabled:
			#move._notation_suffix += piece.data.algebraic_notation
		#Match.move_history.append(AlgebraicNotaion.get_notation(move))


## Sets up the next turn
func next_turn() -> void:
	_apply_turn_end_modifiers()
	_update_modifier_lifetimes()

	# increments the turn number
	Match.turn_num += 1

	Player.previous = Player.current
	Player.current = Match.get_opponent_of(Player.previous)

	turn_changed.emit()

	if Player.current == Player.en_passant:
		# clear en passant
		PieceObject.en_passant = null
		TileObject.en_passant = null

	_update_poisoned_pieces()
	_update_smokey_visuals()

	data.legal_moves.generate_legal_moves(Player.current)

	if Match.is_timed and NetworkManager.is_online:
		NetworkSync.timer_start.rpc(Time.get_unix_time_from_system())

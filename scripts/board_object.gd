class_name BoardObject
extends Node3D


signal turn_changed()
signal game_state_changed(game_state: int)
signal promotion_verified(piece: PieceObject)

#signal _game_overlay_ready()


#const MATCH_SELECTION_SCREEN:PackedScene = preload("uid://bmtcaraovyhdt")
#const TILE_MODIFIER_MENU:PackedScene = preload("uid://b1twmfuyqv1lx")
#const GAME_OVERLAY: PackedScene = preload("uid://b2b5f3ejhqp35")
#const PAUSE_MENU: PackedScene = preload("uid://dh0xqsvmtokbh")
const SMOKE: PackedScene = preload("uid://6mhxpvgl814g")
#const WAIT_SCREEN: PackedScene = preload("uid://crgfep2xyg10g")

#var match_selection_screen: Node
#var tile_modifier_menu: Node
var _game_overlay: Node
#var _pause_menu: Node


var smokey_overlay: Dictionary = {}
var smokey_tiles: Array[TileObject] = []
var smokey_pieces: Array[PieceObject] = []


var data: BoardData


@onready var board_base = $BoardBase
@onready var _piece_capture_audio = $Piece_capture
@onready var _piece_move_audio = $Piece_move


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

	#_instantiate_gamemode_selection_menu()

	if NetworkManager.is_online and not multiplayer.is_server():
		_show_loading_screen()

func _show_loading_screen() -> void:
	var wait_layer = CanvasLayer.new()
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


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#if match_selection_screen:
			#if tile_modifier_menu:
				#_on_tile_modifier_screen_back_button_pressed()
			#else:
				#_on_gamemode_selection_back_button_pressed()
		#elif _game_overlay:
			#if _pause_menu:
				#_on_pause_menu_resume_button_pressed()
			#else:
				#_on_game_overlay_pause_button_pressed()

#@rpc("authority", "call_remote", "reliable")
#func _sync_time_control(time_sec: int, increment_sec: int) -> void:
	#Match.is_timed = true
	#TimeControl.increment_sec = increment_sec
	#TimeControl.max_time_sec = time_sec
	#Match.players.white.timer = TimeControl.new(%TimerWhite, time_sec)
	#Match.players.black.timer = TimeControl.new(%TimerBlack, time_sec)

#region UI and Menu Functions
	#region GAMEMODE_SELECTION_MENU
#func _instantiate_gamemode_selection_menu():
	#match_selection_screen = MATCH_SELECTION_SCREEN.instantiate()
	#$MenuLayer.add_child(match_selection_screen)
	#match_selection_screen.back_button_pressed.connect(
			#Callable(self,"_on_gamemode_selection_back_button_pressed"))
	#match_selection_screen.continue_button_pressed.connect(
			#Callable(self,"_on_gamemode_selection_continue_button_pressed"))
	#match_selection_screen.board_verified.connect(
			#Callable(self,"_on_gamemode_selection_board_verified"))
	#match_selection_screen.start_button_pressed.connect(
			#Callable(self,"_on_gamemode_selection_start_button_pressed"))
	#match_selection_screen.time_control_selected.connect(
			#Callable(self,"_on_gamemode_selection_time_control_selection"))

#func _on_gamemode_selection_time_control_selection(time_sec: int, increment_sec: int):
	#Match.is_timed = true
	#TimeControl.increment_sec = increment_sec
	#TimeControl.max_time_sec = time_sec
#
	#Match.players.white.timer = TimeControl.new(%TimerWhite,time_sec)
	#Match.players.black.timer = TimeControl.new(%TimerBlack,time_sec)
#
	#if NetworkManager.is_online:
		#NetworkSync.time_control.rpc(time_sec, increment_sec)


#func _on_gamemode_selection_back_button_pressed() -> void:
	#get_tree().change_scene_to_file("uid://2aw5r4ibxl8k")


#func _on_gamemode_selection_board_verified(rank_num:int,file_num:int,FEN_notation: FEN) -> void:
	#data.FEN_board_state = FEN_notation
	#data.rank_count = rank_num
	#data.file_count = file_num


#func _on_gamemode_selection_continue_button_pressed() -> void:
	#_instantiatetile_modifier_menu()
	#match_selection_screen.hide()
	#generate_board()
	#load_FEN(data.FEN_board_state)
	#Match.current_game_state = Match.GameState.BOARD_CUSTOMIZATION
	#for tile in get_tree().get_nodes_in_group("Tile"):
		#tile.clicked.connect(Callable(self,"_on_tile_clicked"))

#func _on_gamemode_selection_start_button_pressed():
	#Match.current_game_state = Match.GameState.GAMEPLAY
	#Match.game_state_changed.emit(Match.current_game_state)
	#generate_board()
	#load_FEN(data.FEN_board_state)
	#for tile in get_tree().get_nodes_in_group("Tile"):
		#tile.clicked.connect(Callable(self,"_on_tile_clicked"))
#
	#if NetworkManager.is_online:
		#await get_tree().create_timer(0.5).timeout
		#NetworkSync.board_setup.rpc(data.file_count, data.rank_count, data.FEN_board_state.FE_notation)
		#NetworkSync.tile_modifiers.rpc(_serialize_tile_modifiers())
		#if Match.is_timed:
			#NetworkSync.time_control.rpc(TimeControl.max_time_sec, TimeControl.increment_sec)
		#NetworkSync.gameplay_start.rpc()
#
	#_instantiate_game_overlay()
#
	#match_selection_screen.hide()
	#match_selection_screen.queue_free()

	#endregion


	#region TILE_MODIFIER_MENU
#func _instantiatetile_modifier_menu():
	#tile_modifier_menu =TILE_MODIFIER_MENU.instantiate()
	#$MenuLayer.add_child(tile_modifier_menu)
	#tile_modifier_menu._connect_to_back_button(
			#Callable(self, "_on_tile_modifier_screen_back_button_pressed"))
	#tile_modifier_menu._connect_to_continue_button(
			#Callable(self, "_on_tile_modifier_screen_continue_button_pressed"))
	#tile_modifier_menu._connect_to_host_button(
			#Callable(self, "_on_tile_modifier_screen_host_button_pressed"))

#func _on_tile_modifier_screen_back_button_pressed() -> void:
	#for child in board_base.get_children():
		#if child.occupant:
			#child.occupant.data.player.remove_piece(child.occupant)
		#board_base.remove_child(child)
		#child.queue_free()
#
	#data.tile_array.clear()
	#data.piece_array.clear()

	#match_selection_screen.show()
	#tile_modifier_menu.hide()
	#tile_modifier_menu.queue_free()

#func _on_tile_modifier_screen_continue_button_pressed() -> void:
	#Match.current_game_state = Match.GameState.GAMEPLAY
	#Match.game_state_changed.emit(Match.current_game_state)
	#get_tree().call_group("Tile","clear_states")
	#get_tree().call_group("Tile","remove_from_group","Selected")
	#_instantiate_game_overlay()
#
	#if NetworkManager.is_online:
		#NetworkSync.gameplay_start.rpc()
	#tile_modifier_menu.hide()
	#tile_modifier_menu.queue_free()

#func _on_tile_modifier_screen_host_button_pressed() -> void:
	#var result = NetworkManager.host_game()
	#if result.is_empty():
		#return
	#var wait_layer = CanvasLayer.new()
	#wait_layer.layer = 10
	#add_child(wait_layer)
	#var wait_screen = WAIT_SCREEN.instantiate()
	#wait_layer.add_child(wait_screen)
	#wait_screen.set_ip_label(result["ip"])
	#wait_screen.set_invite_code_label(result["code"])

	#NetworkManager.connected_to_game.connect(
		#func():
				#wait_screen.queue_free()
				#await get_tree().create_timer(1.0).timeout
				#NetworkSync.board_setup.rpc(data.file_count, data.rank_count, data.FEN_board_state.FE_notation)
				#NetworkSync.tile_modifiers.rpc(_serialize_tile_modifiers())
				#if Match.is_timed:
					#NetworkSync.time_control.rpc(TimeControl.max_time_sec, TimeControl.increment_sec)
				#NetworkSync.gameplay_start.rpc()
				#_on_tile_modifier_screen_continue_button_pressed()
				#)

#@rpc("authority", "call_remote", "reliable")
#func _sync_gameplay_start() -> void:
	#Match.current_game_state = Match.GameState.GAMEPLAY
	#Match.game_state_changed.emit(Match.current_game_state)
#
	#if tile_modifier_menu:
		#tile_modifier_menu.hide()
		#tile_modifier_menu.queue_free()
	#if match_selection_screen:
		#match_selection_screen.hide()
		#match_selection_screen.queue_free()
#
	#_hide_loading_screen()
	#_instantiate_game_overlay()
#
	#data.legal_moves = MoveList.new(data)
	#data.legal_moves.generate_legal_moves(Player.current)

	#endregion


	#region GAME_OVERLAY
#func _instantiate_game_overlay():
	#_game_overlay = GAME_OVERLAY.instantiate()
	#_game_overlay.ready.connect(Callable(self,"_on_game_overlay_ready"))
	#$MenuLayer.add_child(_game_overlay)
	#_game_overlay._connect_to_pause_button(
			#Callable(self,"_on_game_overlay_pause_button_pressed"))
	#_game_overlay.new_placement_selected.connect(
			#Callable(self,"_on_game_overlay_new_placement_selected"))
	#_game_overlay._connect_to_rulebook_button(Callable(self,"_on_game_overlay_rulebook_button_pressed"))

	#if Match.is_timed:
		#_game_overlay.show_timers()
		#Match.players.white.timer.label = _game_overlay._get_ui_timer_white()
		#Match.players.black.timer.label = _game_overlay._get_ui_timer_black()

#func _on_game_overlay_ready():
	#_game_overlay_ready.emit()

#func _connect_to_game_overlay_horizontal_camera_slider(function: Callable):
	#_game_overlay.horizontal_slider.value_changed.connect(function)
#
#func _connect_to_game_overlay_forward_camera_slider(function: Callable):
	#_game_overlay.forward_slider.value_changed.connect(function)

#func _on_game_overlay_pause_button_pressed():
	#_pause_menu = PAUSE_MENU.instantiate()
	#$MenuLayer.add_child(_pause_menu)
	#_game_overlay.hide()
#
	#get_tree().paused = true
	#_pause_menu._connect_to_resume_button(
			#Callable(self,"_on_pause_menu_resume_button_pressed"))
	#_pause_menu._connect_to_leave_button(
			#Callable(self,"_on_pause_menu_leave_button_pressed"))


#func _on_game_overlay_rulebook_button_pressed():
	#pass

#func _on_game_overlay_new_placement_selected(placement: FEN) -> void:
	#data.piece_array.clear()
	#for tile in data.tile_array:
		#if tile.occupant:
			#var piece: PieceObject = tile.occupant
			#tile.occupant = null
			#tile.remove_child(piece)
			#piece.data.player.remove_piece(piece)
			#piece.queue_free()
#
	#data.piece_array.resize(data.rank_count * data.file_count)
	#load_FEN(placement)

	#endregion


	#region PAUSE_MENU

#func _on_pause_menu_resume_button_pressed():
	#get_tree().paused = false
	#_pause_menu.hide()
	#_game_overlay.show()
	#_pause_menu.queue_free()
#
#func _on_pause_menu_leave_button_pressed():
	#get_tree().paused = false
	#get_tree().change_scene_to_file("uid://2aw5r4ibxl8k")

	#endregion

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

#@rpc("authority", "call_remote", "reliable")
#func _sync_tile_modifiers(modifier_data: Dictionary) -> void:
	#for tile_index in modifier_data.keys():
		#var tile: TileObject = data.tile_array[tile_index]
		#var new_modifier_order: Array[TileModifier] = []
		#for entry in modifier_data[tile_index]:
			#var modifier: TileModifier = load(entry["script"]).new()
			#match modifier.flag:
				#TileModifier.ModifierType.CONDITION_ICY:
					#modifier.lifetime = entry["lifetime"]
				#TileModifier.ModifierType.CONDITION_STICKY:
					#modifier.lifetime = entry["lifetime"]
				#TileModifier.ModifierType.PROPERTY_BUTTON:
					#modifier.radius = entry["radius"]
				#TileModifier.ModifierType.PROPERTY_COG:
					#modifier.rotation = entry["rotation"]
				#TileModifier.ModifierType.PROPERTY_CONVEYER:
					#modifier.direction = entry["direction"]
				#TileModifier.ModifierType.PROPERTY_GATE:
					#modifier.is_active = entry["is_active"]
				#TileModifier.ModifierType.PROPERTY_LEVER:
					#modifier.radius = entry["radius"]
				#TileModifier.ModifierType.PROPERTY_POISON:
					#modifier.lifetime = entry["lifetime"]
					#modifier.duration = entry["duration"]
				#TileModifier.ModifierType.PROPERTY_SMOKEY:
					#modifier.is_active = entry["is_active"]
				#TileModifier.ModifierType.PROPERTY_SPRINGY:
					#modifier.destination = Vector2i(entry["destination_x"], entry["destination_y"])
			#new_modifier_order.append(modifier)
		#tile.data.modifier_order = new_modifier_order

#@rpc("authority", "call_remote", "reliable")
#func _sync_board_setup(file_count: int, rank_count: int, fen_string: String) -> void:
	#if fen_string.is_empty():
		#return
	#data.file_count = file_count
	#data.rank_count = rank_count
	#data.FEN_board_state = FEN.new(fen_string)
	#generate_board()
	#load_FEN(data.FEN_board_state)
	#Match.current_game_state = Match.GameState.BOARD_CUSTOMIZATION
	#for tile in get_tree().get_nodes_in_group("Tile"):
		#tile.clicked.connect(Callable(self, "_on_tile_clicked"))
#endregion

func _is_my_turn() -> bool:
	var current_player_index: int = 0 if Player.current == Match.players.white else 1
	return NetworkManager.is_my_turn(current_player_index)

func _submit_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_tile_index: int = -1) -> void:
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

	if flags & Move.Type.EN_PASSANT:
		_capture_piece(PieceObject.en_passant)
		perform_move(Move.new(from_tile, to_tile, flags))

	elif flags & Move.Type.CAPTURING:
		_capture_piece(to_tile.occupant)
		perform_move(Move.new(from_tile, to_tile, flags))

	elif flags & (Move.Type.CASTLING_KINGSIDE | Move.Type.CASTLING_QUEENSIDE):
		_perform_castling_move(to_tile)

	else:
		perform_move(Move.new(from_tile, to_tile, flags))

	if Match.is_promotion_occuring:
		await to_tile.occupant.promoted
		Match.is_promotion_occuring = false

	next_turn()

func generate_board() -> void:
	data.tile_array.resize(data.file_count * data.rank_count)
	data.piece_array.resize(data.file_count * data.rank_count)

	# Change the size of the board base to match the size of the board
	$BoardBase.mesh.size = Vector3(data.file_count+1 ,0.2, data.rank_count+1)

	for tile_num in range(data.rank_count * data.file_count):
		var new_tile:TileObject = TileObject.new_tile(tile_num)
		new_tile.data.board_position = data.get_board_position(new_tile.data.index)

		data.tile_array[tile_num] = new_tile
		# move tile to its location on the board
		new_tile.translate(Vector3(
				new_tile.data.file-(float(data.file_count)/2)+0.5,
				0.1,
				(float(data.rank_count)/2)-new_tile.data.rank-0.5
			))
		$BoardBase.add_child(new_tile, true)


func load_FEN(FE_notation:FEN) -> void:
	var fen_decoder := FENDecoder.new(FE_notation)
	data.FEN_board_state = FE_notation
	get_tree().call_group("Tile","clear_states")
	fen_decoder.apply()

	data.legal_moves = MoveList.new(data)
	data.legal_moves.generate_legal_moves(Player.current)

	_clear_check()
	detect_check(Player.current)


func detect_check(player:Player) -> void:
	var player_king: PieceObject = player.pieces["King"][0]
	var player_king_tile: TileObject = data.tile_array[player_king.data.index]

	var opponent_moves: MoveList = MoveList.new(data)
	opponent_moves.generate_pseudo_legal_moves(Match.get_opponent_of(player))

	for move in opponent_moves.moves:
		if (	move.destination_tile.occupant
				and move.destination_tile.occupant.is_in_group("King")
				and move.destination_tile.occupant.is_in_group(player.name)
				):
			player_king_tile._set_check()
			break


func _clear_check() -> void:
	for tile in data.tile_array:
		if tile.data.is_checked:
			tile._unset_check()


func _set_en_passant(clicked_tile: TileObject) -> void:
	PieceObject.en_passant = PieceObject.selected
	var en_passant_tile_rank = (
			TileObject.selected.data.rank
			+ (clicked_tile.data.rank - TileObject.selected.data.rank)/2
			)
	var en_passant_tile_file = TileObject.selected.data.file
	TileObject.en_passant = data.tile_array[data.get_index(en_passant_tile_rank,en_passant_tile_file)]
	Player.en_passant = Player.current

#func _perform_promotion(piece: PieceObject) -> void:
	#if piece == null:
		#return
	#if not piece.data.can_promote:
		#return
#
	#var mouse_pos = get_viewport().get_mouse_position()
	#_game_overlay._show_promotion_menu(mouse_pos)
	#_game_overlay.promotion_piecetype_selected.connect(Callable(piece,"promote"))
	#get_tree().paused = true
	#await piece.promoted
	#piece.data.movement.set_max_distance(maxi(data.file_count,data.rank_count))
	#_game_overlay._hide_promotion_menu()
	#_game_overlay.promotion_piecetype_selected.disconnect(Callable(piece,"promote"))
	#get_tree().paused = false

# MODIFIER HELPER FUNCTIONS
func _apply_on_piece_enter(move: Move) -> void:
	var destination_tile: TileObject = move.destination_tile
	var piece: PieceObject = destination_tile.occupant

	if destination_tile == null or piece == null:
		return

	for modifier in destination_tile.data.modifier_order:
		modifier.on_piece_enter(piece, move.starting_tile, destination_tile)

var end_turn_modifier_moved: bool = false

func _apply_turn_end_modifiers() -> void:
	var max := 16
	var t := 0
	while t < max:
		end_turn_modifier_moved = false
		for tile in data.tile_array:
			for modifier in tile.data.modifier_order:
				modifier.on_turn_end(tile)
		for tile in data.tile_array:
			data.piece_array[tile.data.index] = tile.occupant
		if not end_turn_modifier_moved:
			break
		t += 1

func _update_modifier_lifetimes() -> void:
	for tile in data.tile_array:
		var updated_modifiers: Array[TileModifier] = []
		for modifier in tile.data.modifier_order:
			var lifetime = modifier.get("lifetime")

			if lifetime == null:
				updated_modifiers.append(modifier)
				continue

			if lifetime == -1:
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
		var tile := data.tile_array[data.get_index(current_pos.x, current_pos.y)]

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

		var tile := data.tile_array[data.get_index(pos.x, pos.y)]
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

#region Tile Clicked
func _on_tile_clicked(clicked_tile: TileObject) -> void:
	if Match.current_game_state == Match.GameState.BOARD_CUSTOMIZATION:
		_customization_tile_select(clicked_tile)
	elif Match.current_game_state == Match.GameState.GAMEPLAY:
		_gameplay_tile_select(clicked_tile)

func _customization_tile_select(clicked_tile: TileObject) -> void:
	if clicked_tile.data.is_selected == true:
		clicked_tile.remove_from_group("Selected")
		clicked_tile._unselect()
	elif clicked_tile.data.is_selected == false:
		clicked_tile.add_to_group("Selected")
		clicked_tile._select()

func _gameplay_tile_select(clicked_tile: TileObject) -> void:
	if NetworkManager.is_online and not _is_my_turn():
		return
	# select clicked tile
	if (	PieceObject.selected == null # no piece selected
			and clicked_tile.occupant != null # Clicked Tile is occupied
			and clicked_tile.occupant.is_in_group(Player.current.name) # occupant piece belongs to current player
			):
		_select_tile(clicked_tile)

	elif PieceObject.selected and TileObject.selected: # object already selected
		if clicked_tile.occupant: # Clicked Tile is occupied

			# Unselect currently selected piece
			if (	PieceObject.selected == clicked_tile.occupant
					and TileObject.selected == clicked_tile # Clicked tile and selected tile are the same
					):
				_unselect_tile()

			# Select a different piece
			elif clicked_tile.occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				_unselect_tile()
				_select_tile(clicked_tile)

			# capture opponent piece
			elif (	not clicked_tile.occupant.is_in_group(Player.current.name) # occupant piece belongs to opponent
					and clicked_tile.data.is_threatened
					):
				_submit_move(TileObject.selected.data.index, clicked_tile.data.index, Move.Type.CAPTURING)

		elif clicked_tile.occupant == null:
			# move selected piece to clicked tile
			if clicked_tile.data.is_movement:
				var ep_piece_idx: int = -1
				var ep_tile_idx: int = -1

				# set en passant if conditions are met
				if (	PieceObject.selected.is_in_group("Pawn")
						and not PieceObject.selected.data.has_moved
						and abs(clicked_tile.data.rank - TileObject.selected.data.rank) == 2 # Pawn piece has moved two tiles
						):
					_set_en_passant(clicked_tile)
					ep_piece_idx = PieceObject.en_passant.data.index
					ep_tile_idx = TileObject.en_passant.data.index

				_submit_move(TileObject.selected.data.index, clicked_tile.data.index, 0, ep_piece_idx, ep_tile_idx)

			# perform castling movement
			elif clicked_tile.data.is_castling:
				_submit_move(TileObject.selected.data.index, clicked_tile.data.index, Move.Type.CASTLING_KINGSIDE | Move.Type.CASTLING_QUEENSIDE)

			# capture pawn via en passant
			elif (	clicked_tile.data.is_threatened
					and TileObject.en_passant == clicked_tile
					and PieceObject.en_passant != null
					and not PieceObject.en_passant.is_in_group(Player.current.name)
					):
						_capture_piece(PieceObject.en_passant)
						_submit_move( TileObject.selected.data.index, clicked_tile.data.index, Move.Type.CAPTURING | Move.Type.EN_PASSANT, PieceObject.en_passant.data.index, TileObject.en_passant.data.index)
#endregion


func _select_tile(tile: TileObject) -> void:
	TileObject.selected = tile
	PieceObject.selected = tile.occupant
	TileObject.selected._select()
	show_selected_piece_movement()


func _unselect_tile() -> void:
	TileObject.selected._unselect()
	TileObject.selected = null
	PieceObject.selected = null
	get_tree().call_group("Tile","clear_states")


func _perform_castling_move(castling_tile: TileObject) -> void:
	var middle_file_value: float = (data.file_count/2) - 1
	var castling_rook_index: int
	var destination_index: int

	# kingside castling
	if castling_tile.data.file > middle_file_value:
		castling_rook_index = data.get_index(
				castling_tile.data.rank,
				data.file_count-1
				)

		destination_index = data.get_index(
				castling_tile.data.rank,
				castling_tile.data.file-1
				)
		perform_move(Move.new(TileObject.selected, castling_tile, Move.Type.CASTLING_KINGSIDE))

	# queenside castling
	elif castling_tile.data.file < middle_file_value:
		castling_rook_index = data.get_index(castling_tile.data.rank,0)
		destination_index = data.get_index(
				castling_tile.data.rank,
				castling_tile.data.file+1
				)
		perform_move(Move.new(TileObject.selected, castling_tile, Move.Type.CASTLING_QUEENSIDE))

	var castling_rook_destination = data.tile_array[destination_index]

	perform_move(Move.new(data.tile_array[castling_rook_index],castling_rook_destination,Move.Type.IGNORE))

## Shows the valid tiles the selected piece can move to
func show_selected_piece_movement() -> void:
	var moveset:Movement = PieceObject.selected.data.movement.get_duplicate()
	#moveset = TileModifier.apply_modifiers_to_moveset(self, TileObject.selected, PieceObject.selected, moveset)
	_resolve_branching_movement(
			PieceObject.selected,
			moveset,
			TileObject.selected
			)


func get_next_tile(current_tile: TileObject, direction:Movement.Direction):
	var next_tile_position: Vector2i = (
			current_tile.data.board_position
			+ Movement.neighboring_tiles[direction]
			)

	if (	next_tile_position.x > data.rank_count-1
			or next_tile_position.x < 0
			or next_tile_position.y > data.file_count-1
			or next_tile_position.y < 0
			):
		return # next_tile does not exist

	return data.tile_array[
			data.get_index(next_tile_position.x,next_tile_position.y)
			]

# SAME LOGIC USED IN MoveList RESOURCE.
# IF THE LOGIC IS CHANGED HERE, MAKE SURE TO CHANGE THAT AS WELL
func _resolve_branching_movement(
		active_piece:PieceObject,
		moveset: Movement,
		origin_tile: TileObject
		) -> void:

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
			current_tile_ptr = get_next_tile(current_tile_ptr, branch.direction)

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
					var next_tile = get_next_tile(current_tile_ptr, branch.direction)
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
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece.data.player != current_tile_ptr.occupant.data.player # current_tile_ptr is occupied by opponent piece
						):
					current_tile_ptr._threaten()
					break

				# EN PASSANT LOGIC
				elif ( 	current_tile_ptr.occupant == null	# current_tile_ptr is not occupied
						and PieceObject.en_passant
						and active_piece.data.player != PieceObject.en_passant.data.player
						and current_tile_ptr == TileObject.en_passant
						):
					TileObject.en_passant._threaten()
					PieceObject.en_passant.data.is_threatened = true


			if not branch.is_jump:
				# JUMP LOGIC
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece != current_tile_ptr.occupant # current_tile_ptr not is occupied by active piece
						):
					break


			if branch.is_move:
				#MOVEMENT LOGIC
				if current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					var possible_move: Array[TileObject] = [data.tile_array[active_piece.data.index], current_tile_ptr]
					if data.legal_moves.contains_move(possible_move):
						current_tile_ptr.data.is_movement = true
					else:
						current_tile_ptr.data.is_checked_movement = true

						# King cannot castle through checked tile
						if active_piece.data.name == "King":
							if branch.direction == Movement.Direction.EAST:
								active_piece.data.set_meta("is_castling_kingside_valid", false)
							elif branch.direction == Movement.Direction.WEST:
								active_piece.data.set_meta("is_castling_queenside_valid", false)


			if branch.is_castling:
				var king_tile: TileObject = TileObject.selected

				if (	active_piece.data.has_moved # if king has moved
						or active_piece.data.is_checked # if king is in check
						or (	branch.direction == Movement.Direction.EAST
								and not active_piece.data.get_meta("is_castling_kingside_valid"))	# if east tile is checked
						or (	branch.direction == Movement.Direction.WEST
								and not active_piece.data.get_meta("is_castling_queenside_valid")) # if west tile is checked
						):
					break

				# Get rook tile for current castling side
				var rook_tile: TileObject
				if current_tile_ptr.data.board_position > king_tile.data.board_position:
					rook_tile = data.tile_array[data.get_index(king_tile.data.rank,data.file_count-1)]
				elif current_tile_ptr.data.board_position < king_tile.data.board_position:
					rook_tile = data.tile_array[data.get_index(king_tile.data.rank,0)]

				if (	not rook_tile.occupant # if no occupant
						or not rook_tile.occupant.is_in_group("Rook") # if occupant is not a rook
						or rook_tile.occupant.data.has_moved # if rook has moved
						):
					break

				# equation gives either 1 or -1
				var range_increment_direction:int = (
						(rook_tile.data.file - king_tile.data.file)
						/ abs(rook_tile.data.file - king_tile.data.file)
						)

				var is_empty_between_pieces: bool = true
				for tile_file in range(king_tile.data.file + range_increment_direction, rook_tile.data.file, range_increment_direction):
					if data.tile_array[data.get_index(king_tile.data.rank,tile_file)].occupant:
						is_empty_between_pieces = false

				if not is_empty_between_pieces: # tiles between rook and king are occupied
					break

				if data.legal_moves.contains_move([data.tile_array[active_piece.data.index], current_tile_ptr]):
					rook_tile.occupant.data.is_castling = true
					current_tile_ptr._show_castling()


			distance -= 1


		if branch.is_branching and distance == 0:
			_resolve_branching_movement(active_piece, branch, current_tile_ptr)


func _capture_piece(piece) -> void:
	piece._captured()
	_piece_capture_audio.play()


func perform_move(move: Move):
	_clear_check()
	get_tree().call_group("Tile","clear_states")
	var piece: PieceObject = move.starting_tile.occupant
	move.starting_tile.occupant = null

	move.destination_tile.occupant = piece
	piece.global_position = (piece.position * Vector3(0,1,0)) + move.destination_tile.global_position
	piece.global_rotation = move.destination_tile.global_rotation + piece.global_rotation
	piece.reparent(move.destination_tile)
	piece.data.index = move.destination_tile.data.index
	_piece_move_audio.play()

	if not piece.data.has_moved:
		piece._moved(true)

	_apply_on_piece_enter(move) # used for poison, kings favor, smokey, and button
	_apply_on_piece_pass(move) # used only for lever

	# match occupants in piece_array to their respective tiles in tile_array
	for tile in data.tile_array:
		data.piece_array[tile.data.index] = tile.occupant

	# determine if check or checkmate has occured
	var opponent_moves:= MoveList.new(data)
	opponent_moves.generate_legal_moves(Match.get_opponent_of(Player.current))
	if opponent_moves.moves.is_empty():
		move.flags += Move.Type.CHECKMATE
		_game_overlay.show_checkmate(Player.current)


	detect_check(Match.get_opponent_of(Player.current))
	if not opponent_moves.moves.is_empty() and Match.get_opponent_of(Player.current).pieces["King"][0].data.is_checked:
		move.flags += Move.Type.CHECK

	if piece.data.can_promote and move.destination_tile.data.rank == piece.data.player.promotion_rank:
		move.flags += Move.Type.PROMOTION
		Match.is_promotion_occuring = true
		promotion_verified.emit(piece)

	if not piece.data.has_moved:
		piece._moved(true)

	#if move.algebraic_notation != "": # empty string due to castling move
		#if move.flags & Move.Type.PROMOTION:
			#move._notation_suffix += piece.data.algebraic_notation
		#_game_overlay.add_move(move)


## Sets up the next turn
func next_turn() -> void:
	_apply_turn_end_modifiers()
	_update_modifier_lifetimes()
	#_game_overlay.horizontal_slider.value = 0
	#_game_overlay.forward_slider.value = 0

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


#@rpc("authority", "call_remote", "reliable")
#func _sync_timer_start(host_timestamp: float) -> void:
	#var latency_sec: float = Time.get_unix_time_from_system() - host_timestamp
	#Player.current.timer.start_timer()
	#Player.current.timer.reduce_by(latency_sec)

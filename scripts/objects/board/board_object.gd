class_name BoardObject
extends Node3D


signal turn_changed()
signal promotion_verified(piece: PieceObject)
signal player_to_move_changed(new_player_data: Player)
signal board_representation_changed()

enum {
	TILE_DATA_INDEX = 0,
	PIECE_DATA_INDEX = 1
	}

@export var player_component: PlayerComponent
@export var tile_grid: TileGridComponent
@export var board_base: MeshInstance3D
@export var rules_component: RulesComponent

@export_group("Audio","audio_")
@export var audio_piece_capture:AudioStreamPlayer
@export var audio_piece_move:AudioStreamPlayer


var fen:FEN = FEN.new("rnbqkbnr/pppppppp/8/7B/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")


var board_history: Array[BoardChange] = []


var current_changes: BoardChange


var castling_rights: Dictionary = {
	"white": {
		"kingside": true,
		"queenside": true,
	},
	"black": {
		"kingside": true,
		"queenside": true,
	},
}


# Defines the Tile a pawn must land on to capture Piece.
# Piece is not on Tile.
var en_passant: Dictionary = {
	"tile": null,
	"piece": null
}


var fullmove_counter: int = 0


var selected_tile: TileObject:
	get = _selected_tile_getter


var valid_selections: Array = []
var valid_destinations: Dictionary[PieceObject,Dictionary] = {
	#PieceObject: {TileObject: ObjectStateComponent.STATE, ...}
}


#region Getter/Setters
func _selected_tile_getter() -> TileObject:
	var selected_tile_array: Array = TileStateComponent.get_tiles_on_states(ObjectStateComponent.STATE_SELECTED)
	if selected_tile_array.is_empty(): return null
	else: return selected_tile_array.front()
#endregion


func _ready() -> void:
	tile_grid.object_clicked.connect(_on_object_clicked)
	player_component.player_to_move_changed.connect(_on_player_to_move_changed)

	tile_grid.generate_tile_grid(8,8)
	_resize_base(tile_grid.rank_count,tile_grid.file_count)
	_on_player_to_move_changed(player_component.player_to_move)

	player_component.player_dictionary.white.promotion_rank = tile_grid.rank_count - 1
	player_component.player_dictionary.black.promotion_rank = 0

#
	#if NetworkManager.is_online:
		#NetworkManager.opponent_disconnected.connect(_on_opponent_disconnected)
#
	#if NetworkManager.is_online and multiplayer.is_server():
		#multiplayer.peer_connected.connect(_on_peer_connected_resync)
#
	#if NetworkManager.is_online and not multiplayer.is_server():
		#_show_loading_screen()


func _on_object_clicked(tile: InteractableGameObject) -> void:
	if tile in valid_selections:
		tile.select_object()
		_toggle_destination_states(tile)
	elif is_instance_valid(selected_tile) and tile in valid_destinations.get(selected_tile.occupant).keys():
		process_move(selected_tile, tile)


#region Board Generation
# This is not run through the _init function because there are some cases where
# we do not want to generate new tiles when creating a new board.
#func generate_board(ranks:int = 8, files:int = 8) -> void:
#
	#_resize_base(ranks,files) # Change the size of the board base to match the size of the board
#
	#if board_representation.is_empty():
		#_generate_position_vectors()
		#_generate_tile_data()
#
	#_assign_tile_neighbors()
	#_generate_pieces()
	#_set_player_to_move()


func _resize_base(ranks: int,files:int) -> void:
	const BASE_WIDTH: float = 0.2
	board_base.mesh.size = Vector3(files+1,BASE_WIDTH,ranks+1)


#func _assign_data_to_tiles(new_data:BoardObject) -> void:
	#if new_data.tiles.size() != tile_grid.tile_list.size():
		#return
	#for index:int in range(tile_grid.tile_list.size()):
		#if not tile_grid.tile_list[index] in board_base.get_children():
			#board_base.add_child(tile_grid.tile_list[index])
		#tile_grid.tile_list[index].data = new_data.tiles[index]
#
#
#func _generate_piece_objects(new_data:BoardObject) -> void:
	#var counter:int = tile_grid.piece_list.size()
	#var number_of_pieces:int = new_data.pieces.size()
#
	#if counter < number_of_pieces:
		#while counter < number_of_pieces:
			#var piece: PieceObject = PieceObject.new_piece_object()
			#piece.clicked.connect(_on_piece_clicked)
			#tile_grid.piece_list.append(piece)
			#counter += 1
	#elif counter > number_of_pieces:
		#while counter > number_of_pieces:
			#tile_grid.piece_list.pop_back().queue_free()
			#counter -= 1
#
#
#func _assign_data_to_pieces(new_data:BoardObject) -> void:
	#if new_data.pieces.size() != tile_grid.piece_list.size():
		#return
	#for index:int in range(tile_grid.piece_list.size()):
		#tile_grid.piece_list[index].data = new_data.pieces[index]
#
#
#func _place_pieces(new_data:BoardObject)-> void:
	#for piece_object: PieceObject in tile_grid.piece_list:
		#var position_vector: Vector2i = piece_object.data.position_vector
		#if position_vector in new_data.board_representation.keys():
			#var board_location: Array = new_data.board_representation[position_vector]
			#var assigned_tile: TileObject = board_location.get(BoardObject.TILE_DATA_INDEX).assigned_object
			#assigned_tile.add_child(piece_object)
			#assigned_tile.occupant = piece_object
#endregion


#region Object Selected
#func _on_piece_clicked(piece:PieceObject) -> void:
	#if piece in valid_selections:
		#piece.state.set_state(ObjectStateComponent.STATE_SELECTED)
#
#
#func _on_tile_clicked(tile:TileObject)-> void:
	#if tile in valid_selections:
		#tile.state.set_state(ObjectStateComponent.STATE_SELECTED)
		#_toggle_destination_states(tile)
	#elif is_instance_valid(selected_tile) and tile in valid_destinations.get(selected_tile.occupant).keys():
		#process_change(selected_tile, tile)


func _toggle_destination_states(tile: TileObject) -> void:
	var destinations: Dictionary[TileObject,StringName] = valid_destinations.get(tile.occupant)
	for tile_index:TileObject in destinations.keys():
		tile_index.state.set_state(destinations.get(tile_index))
		if is_instance_valid(tile_index.occupant):
			tile_index.occupant.state.set_state(destinations.get(tile_index))
#endregion


func print_properties() -> void:
	var property_list: Array[Dictionary] = get_property_list()
	var property_dict: Dictionary[StringName,Variant] = {}
	for property in property_list:
		property_dict.set(property.name,get(property.name))

	DebugPrinter.print_pretty(property_dict, false)


#func _ready(ranks:int = 8, files:int = 8) -> void:
#
	#GameData.players.white.promotion_rank = rank_count - 1
	#GameData.players.black.promotion_rank = 0
#
	#player_to_move_changed.connect(_on_player_to_move_changed)
#
#
#func _generate_position_vectors() -> void:
	#for index in range(tile_grid.rank_count*tile_grid.file_count):
		#board_representation.set(Vector2i(index/tile_grid.file_count, index%tile_grid.file_count),[])


func _on_player_to_move_changed(new_player:Player) -> void:
	valid_selections.clear()
	valid_destinations.clear()
	_find_all_valid_selections(new_player)
	_find_all_valid_destinations()


func _find_all_valid_selections(new_player:Player) -> void:
	var piece_filter:Callable = func(piece: PieceObject) -> bool: return piece.player_ownership.player == new_player
	var selectable_piece_objects:Array[PieceObject] = tile_grid.piece_list.filter(piece_filter)
	valid_selections.append_array(selectable_piece_objects)

	var tile_filter:Callable = func(tile: TileObject) -> bool: return selectable_piece_objects.has(tile.occupant)
	var selectable_tile_object: Array[TileObject] = tile_grid.tile_list.filter(tile_filter)
	valid_selections.append_array(selectable_tile_object)


func _find_all_valid_destinations() -> void:
	var destinations: Dictionary[PieceObject,Dictionary] = {}

	var selectable_pieces: Array = valid_selections.filter(
			func(item:Object) -> bool: return (item is PieceObject)
		)
	for piece:PieceObject in selectable_pieces:
		destinations.set(piece,_find_movement_of_piece(piece))

	# filter out moves

	valid_destinations = destinations


func _find_movement_of_piece(piece:PieceObject) -> Dictionary[TileObject,StringName]:
	var movement: Dictionary[TileObject,StringName] = {}
	var starting_tile: TileObject = tile_grid.get_tile_at_position(piece.position_vector)
	movement = piece.movement_component.movement.apply_movement(starting_tile, self)
	piece.movement_component.reset_movement()
	return movement


func process_move(from: TileObject, to: TileObject) -> void:
	current_changes = BoardChange.new()

	var move: Dictionary = {
		"moving_player": player_component.player_to_move,
		"occupant": from.occupant,
		"from": from,
		"to": to,
	}

	current_changes.add_change(BoardChange.MOVE_RULE_NAME, move)
	if is_instance_valid(to.occupant):
		current_changes.add_change(BoardChange.CAPTURED_RULE_NAME,[to.occupant])
	current_changes.add_change(BoardChange.PLAYER_TO_MOVE_RULE_NAME, player_component.opponent(player_component.player_to_move))

	get_tree().get_nodes_in_group("isRuled").map(
		func(node:Node): node.rules_component.evaluate_rules(self)
	)

	DebugPrinter.print_pretty(current_changes.changed_data)
	BoardChange.apply_change(current_changes,self)
	tile_grid.update_lists()


func _evaluate_piece_rules(current_changes: BoardChange) -> void:
	for piece:PieceObject in tile_grid.piece_list:
		piece.evaluate_rules(current_changes)

# ===============================================================================
# ============================== [END OF REFACTOR] ==============================
# ===============================================================================

#const SMOKE: PackedScene = preload("uid://6mhxpvgl814g")
#
#var smokey_overlay: Dictionary = {}
#var smokey_tiles: Array[TileObject] = []
#var smokey_pieces: Array[PieceObject] = []
#
##region multilplayer
#func _show_loading_screen() -> void:
	#var wait_layer := CanvasLayer.new()
	#wait_layer.layer = 10
	#wait_layer.name = "LoadingLayer"
	#add_child(wait_layer)
	#var loading = preload("uid://v4i5knax4g12").instantiate()
	#wait_layer.add_child(loading)
#
#
#func _hide_loading_screen() -> void:
	#var loading_layer = get_node_or_null("LoadingLayer")
	#if loading_layer:
		#loading_layer.queue_free()
#
#
#func _on_peer_connected_resync(_id: int) -> void:
	#if Match.current_game_state == Match.GameState.GAMEPLAY:
		#await get_tree().create_timer(0.5).timeout
		#NetworkSync.board_setup.rpc(file_count, rank_count, FEN_board_state.FE_notation)
		#await get_tree().create_timer(0.5).timeout
		#NetworkSync.tile_modifiers.rpc(_serialize_tile_modifiers())
		#NetworkSync.gameplay_start.rpc()
#
#
#func _on_opponent_disconnected() -> void:
	#get_tree().paused = true
	#print("Opponent disconnected. Game paused.")
#
#
#func _serialize_tile_modifiers() -> Dictionary:
	#var result: Dictionary = {}
	#for tile in data.tile_array:
		#if tile.data.modifier_order.is_empty():
			#continue
		#var modifier_list: Array = []
		#for modifier in tile.data.modifier_order:
			#var entry: Dictionary = {
				#"script": modifier.get_script().resource_path
			#}
			#match modifier.flag:
				#TileModifier.ModifierType.CONDITION_ICY:
					#entry["lifetime"] = modifier.lifetime
				#TileModifier.ModifierType.CONDITION_STICKY:
					#entry["lifetime"] = modifier.lifetime
				#TileModifier.ModifierType.PROPERTY_BUTTON:
					#entry["radius"] = modifier.radius
				#TileModifier.ModifierType.PROPERTY_COG:
					#entry["rotation"] = modifier.rotation
				#TileModifier.ModifierType.PROPERTY_CONVEYER:
					#entry["direction"] = modifier.direction
				#TileModifier.ModifierType.PROPERTY_GATE:
					#entry["is_active"] = modifier.is_active
				#TileModifier.ModifierType.PROPERTY_LEVER:
					#entry["radius"] = modifier.radius
				#TileModifier.ModifierType.PROPERTY_POISON:
					#entry["lifetime"] = modifier.lifetime
					#entry["duration"] = modifier.duration
				#TileModifier.ModifierType.PROPERTY_SMOKEY:
					#entry["is_active"] = modifier.is_active
				#TileModifier.ModifierType.PROPERTY_SPRINGY:
					#entry["destination_x"] = modifier.destination.x
					#entry["destination_y"] = modifier.destination.y
			#modifier_list.append(entry)
		#result[tile.data.index] = modifier_list
	#return result
#
#func submit_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_TILE_DATA_INDEX: int = -1) -> void:
	#_execute_move(from_index, to_index, flags, ep_piece_index, ep_TILE_DATA_INDEX)
	#if NetworkManager.is_online:
		#_sync_move.rpc(from_index, to_index, flags, ep_piece_index, ep_TILE_DATA_INDEX)
#
#@rpc("any_peer", "call_remote", "reliable")
#func _sync_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_TILE_DATA_INDEX: int = -1) -> void:
	#_execute_move(from_index, to_index, flags, ep_piece_index, ep_TILE_DATA_INDEX)
#
#func _execute_move(from_index: int, to_index: int, flags: int, ep_piece_index: int = -1, ep_TILE_DATA_INDEX: int = -1) -> void:
	#var from_tile: TileObject = data.tile_array[from_index]
	#var to_tile: TileObject = data.tile_array[to_index]
#
	#selected_tile = from_tile
	##PieceObject.selected = from_tile.occupant
#
	#if ep_piece_index >= 0 and ep_TILE_DATA_INDEX >= 0:
		#PieceObject.en_passant = data.piece_array[ep_piece_index]
		#TileObject.en_passant = data.tile_array[ep_TILE_DATA_INDEX]
		#Player.en_passant = Player.current
#
	#if flags & Move.Outcome.EN_PASSANT:
		#_capture_piece(PieceObject.en_passant)
		#_perform_move(Move.new(from_tile, to_tile, flags))
#
	#elif flags & Move.Outcome.CAPTURING:
		#_capture_piece(to_tile.occupant)
		#_perform_move(Move.new(from_tile, to_tile, flags))
#
	#elif flags & (Move.Outcome.CASTLING_KINGSIDE | Move.Outcome.CASTLING_QUEENSIDE):
		#_perform_castling_move(to_tile)
#
	#else:
		#_perform_move(Move.new(from_tile, to_tile, flags))
#
	#if Match.is_promotion_occuring:
		#await to_tile.occupant.promoted
		#Match.is_promotion_occuring = false
#
	#next_turn()
##endregion
#
#func load_FEN(FE_notation:FEN) -> void:
	#var fen_decoder := FENDecoder.new(FE_notation)
	#data.FEN_board_state = FE_notation
	#get_tree().notify_group("Tile",TileObject.NOTIFICATION_CLEAR_OTHER_STATES)
	#fen_decoder.apply()
#
	#data.legal_moves = MoveList.new(data)
	#data.legal_moves.generate_legal_moves(Player.current)
#
	#get_tree().notify_group("Tile",TileObject.NOTIFICATION_CLEAR_CHECK_STATE)
	#detect_check(Player.current)
#
#
#
#func detect_check(player:Player) -> void:
	#var player_king: PieceObject = player.pieces["King"][0]
	#var player_king_tile: TileObject = data.tile_array[player_king.data.index]
#
	#var opponent_moves: MoveList = MoveList.new(data)
	#opponent_moves.generate_pseudo_legal_moves(Match.get_opponent_of(player))
#
	#for move in opponent_moves.moves:
		#if (	move.destination_tile.is_occupied
				#and move.destination_tile.occupant.is_in_group("King")
				#and move.destination_tile.occupant.is_in_group(player.name)
				#):
			#player_king_tile.data.change("is_checked",true)
			#break
#
#
#func _set_en_passant(clicked_tile: TileObject) -> void:
	##PieceObject.en_passant = PieceObject.selected
	#var en_passant_tile_rank = (
			#selected_tile.data.rank
			#+ (clicked_tile.data.rank - selected_tile.data.rank)/2
			#)
	#var en_passant_tile_file = selected_tile.data.file
	#TileObject.en_passant = data.tile_array[Match.get_board_index(en_passant_tile_rank,en_passant_tile_file)]
	#Player.en_passant = Player.current
#
#
##region MODIFIER HELPER FUNCTIONS
#func _apply_turn_end_modifiers() -> void:
	#var max := 16
	#var t := 0
	#while t < max:
		#Match.end_turn_modifier_moved = false
		#for tile in data.tile_array:
			#for modifier in tile.data.modifier_order:
				#modifier.on_turn_end(tile)
		#for tile in data.tile_array:
			#data.piece_array[tile.data.index] = tile.occupant
		#if not Match.end_turn_modifier_moved:
			#break
		#t += 1
#
#
#func _update_modifier_lifetimes() -> void:
	#for tile in data.tile_array:
		#var updated_modifiers: Array[TileModifier] = []
		#for modifier in tile.data.modifier_order:
			#var lifetime = modifier.get("lifetime")
#
			#if lifetime == null or lifetime == -1:
				#updated_modifiers.append(modifier)
				#continue
#
			#if lifetime > 0:
				#modifier.lifetime -= 1
#
			#if modifier.lifetime != 0:
				#updated_modifiers.append(modifier)
#
		#tile.data.modifier_order = updated_modifiers
#
#func _update_poisoned_pieces() -> void:
	#for tile in data.tile_array:
		#var piece = tile.occupant
		#if piece == null:
			#continue
		#if not piece.data.is_poisoned:
			#continue
		#if Match.turn_num - piece.data.poison_turn_applied >= piece.data.poison_duration:
			#_capture_piece(piece)
#
#
#func _tile_in_radius(origin_tile, target_tile, radius) -> bool:
	#var delta: Vector2i = target_tile.data.position_vector - origin_tile.data.position_vector
	#return max(abs(delta.x), abs(delta.y)) <= radius # return true if within specified radius
#
#
#func _toggle_gates_in_radius(origin_tile, radius) -> void:
	#print("Toggling gates from ", origin_tile.data.position_vector, " radius=", radius)
	#for tile in data.tile_array:
		#if not _tile_in_radius(origin_tile, tile, radius):
			#continue
#
		#var changed := false
		#for modifier in tile.data.modifier_order:
			#if modifier is PropertyGate:
				#modifier.is_active = not modifier.is_active
				#changed = true
#
		#if changed:
			#tile.data.emit_changed()
#
#
#func _apply_on_piece_pass(move: Move) -> void:
	#var piece: PieceObject = move.destination_tile.occupant
	#if piece == null:
		#return
#
	#var start := move.starting_tile.data.position_vector
	#var dest := move.destination_tile.data.position_vector
	#var delta := dest - start
#
	## Normalize delta or else the movement is strange
	#delta.x = sign(delta.x)
	#delta.y = sign(delta.y)
#
	#var current_pos := start + delta
#
	#while current_pos != dest:
		#if current_pos.x < 0 or current_pos.x >= data.rank_count:
			#break
		#if current_pos.y < 0 or current_pos.y >= data.file_count:
			#break
		##var tile := data.tile_array[Match.get_board_index(current_pos.x, current_pos.y)]
#
		##for modifier in tile.data.modifier_order:
			##if modifier is PropertyLever:
				##modifier.activate(self, tile)
#
		#current_pos += delta
#
#func _get_smokey_tiles(origin_tile: TileObject, smokey: PropertySmokey) -> Array[TileObject]:
	#var out: Array[TileObject] = []
	#var origin := origin_tile.data.position_vector
#
	#var offsets : Array[Vector2i] = []
	#if smokey.activated_by_player == GameData.players.white:
		#offsets = [
			#Vector2i(1, 0),
			#Vector2i(2, 0),
		#]
	#elif smokey.activated_by_player == GameData.players.black:
		#offsets = [
			#Vector2i(-1, 0),
			#Vector2i(-2, 0),
		#]
	#else:
		#return out
#
	#for offset in offsets:
		#var pos : Vector2i = origin + offset
#
		#if pos.x < 0 or pos.x >= data.rank_count:
			#continue
		#if pos.y < 0 or pos.y >= data.file_count:
			#continue
#
		##var tile := data.tile_array[Match.get_board_index(pos.x, pos.y)]
		##if tile != null and not out.has(tile):
			##out.append(tile)
#
	#return out
#
#func _clear_smokey_visuals() -> void:
	#for overlay in smokey_overlay.values():
		#if is_instance_valid(overlay):
			#overlay.queue_free()
	#smokey_overlay.clear()
#
	#for piece in smokey_pieces:
		#if is_instance_valid(piece):
			#piece.visible = true
	#smokey_pieces.clear()
	#smokey_tiles.clear()
#
#
#func _create_smokey_overlay(tile: TileObject) -> void:
	#if smokey_overlay.has(tile):
		#return
#
	#var overlay = SMOKE.instantiate()
	#add_child(overlay)
	#overlay.global_position = tile.global_position + Vector3(0, 1.2, 0)
	#smokey_overlay[tile] = overlay
#
#
#func _update_smokey_visuals() -> void:
	#_clear_smokey_visuals()
#
	#for tile in data.tile_array:
		#for modifier in tile.data.modifier_order:
			#if modifier is PropertySmokey and modifier.is_active:
				#for affected_tile in _get_smokey_tiles(tile, modifier):
					#_create_smokey_overlay(affected_tile)
#
					#if not smokey_tiles.has(affected_tile):
						#smokey_tiles.append(affected_tile)
#
					#if affected_tile.occupant != null:
						#affected_tile.occupant.visible = false
						#if not smokey_pieces.has(affected_tile.occupant):
							#smokey_pieces.append(affected_tile.occupant)
##endregion
#
#func _perform_castling_move(castling_tile: TileObject) -> void:
	#var middle_file_value: float = (data.file_count/2) - 1
	#var castling_rook_index: int
	#var destination_index: int
#
	## kingside castling
	#if castling_tile.data.file > middle_file_value:
		#castling_rook_index = Match.get_board_index(castling_tile.data.rank,data.file_count-1)
		#destination_index = castling_tile.neighbors[Constants.Direction.WEST].data.index
		#_perform_move(Move.new(selected_tile, castling_tile, Move.Outcome.CASTLING_KINGSIDE))
#
	## queenside castling
	#elif castling_tile.data.file < middle_file_value:
		#castling_rook_index = Match.get_board_index(castling_tile.data.rank,0)
		#destination_index = castling_tile.neighbors[Constants.Direction.EAST].data.index
		#_perform_move(Move.new(selected_tile, castling_tile, Move.Outcome.CASTLING_QUEENSIDE))
#
	#var castling_rook_destination = data.tile_array[destination_index]
	#_perform_move(Move.new(data.tile_array[castling_rook_index],castling_rook_destination,Move.Outcome.IGNORE))
#
#
### Shows the valid tiles the selected piece can move to
##func show_selected_piece_movement() -> void:
	##var moveset:OLD_MOVEMENT_CLASS = PieceObject.selected.data.movement.get_duplicate()
	##moveset = TileModifier.apply_modifiers_to_moveset(self, selected_tile, PieceObject.selected, moveset)
	##resolve_branching_movement(PieceObject.selected, moveset, selected_tile )
#
#
## SAME LOGIC USED IN MoveList RESOURCE.
## IF THE LOGIC IS CHANGED HERE, MAKE SURE TO CHANGE THAT AS WELL
#func resolve_branching_movement(active_piece:PieceObject, moveset: OLD_MOVEMENT_CLASS, origin_tile: TileObject) -> void:
#
	#moveset = moveset.duplicate_deep()
#
	#for modifier in origin_tile.data.modifier_order:
		#if modifier.can_modify_movement:
			#modifier.modify_movement(moveset)
#
	#for branch in moveset.branches:
		#var current_tile_ptr: TileObject = origin_tile
		#var distance: int = branch.distance
		#var can_proceed_with_branch: bool = true
		#var has_slid:bool = false
#
		#while distance > 0:
			#current_tile_ptr = current_tile_ptr.neighbors[branch.direction]
#
			#if current_tile_ptr == null:
				#break # current_tile_ptr does not exist
#
			#for modifier in current_tile_ptr.data.modifier_order:
				#if moveset.is_jump:
					#break
#
				#if modifier.is_blocking:
					#distance = 0
					#can_proceed_with_branch = false
					#break
#
				#if modifier.is_stopping:
					#distance = 1
					#moveset.is_branching = false
#
				#if modifier.is_slippery:
					#var next_tile = current_tile_ptr.get_next_tile(branch.direction)
					#if not next_tile.occupant:
						#has_slid = true
						#break
#
				#if modifier.can_modify_movement:
					#modifier.modify_movement(branch)
					#distance = branch.distance
#
			#if has_slid:
				#has_slid = false
				#continue
#
			#if can_proceed_with_branch == false:
				#can_proceed_with_branch = true
				#break
#
#
			#if branch.is_threaten:
				## NORMAL THREATEN LOGIC
				#if (	current_tile_ptr.is_occupied
						#and active_piece.data.player != current_tile_ptr.occupant_data.player # current_tile_ptr is occupied by opponent piece
						#):
					#current_tile_ptr.data.change("is_threatened",true)
					#break
#
				## EN PASSANT LOGIC
				#elif ( 	not current_tile_ptr.is_occupied
						#and PieceObject.en_passant
						#and active_piece.data.player != PieceObject.en_passant.data.player
						#and current_tile_ptr == TileObject.en_passant
						#):
					#TileObject.en_passant.data.change("is_threatened",true)
					#PieceObject.en_passant.data.flag.is_threatened.enabled = true
#
			#if not branch.is_jump:
				## JUMP LOGIC
				#if (	current_tile_ptr.is_occupied
						#and active_piece != current_tile_ptr.occupant # current_tile_ptr not is occupied by active piece
						#):
					#break
#
			#if branch.is_move:
				##MOVEMENT LOGIC
				#if not current_tile_ptr.is_occupied:
					#var possible_move: Array[TileObject] = [data.tile_array[active_piece.data.index], current_tile_ptr]
					#if data.legal_moves.contains_move(possible_move):
						#current_tile_ptr.data.flag.is_movement.enabled = true
					#else:
						#current_tile_ptr.data.flag.is_checked_movement.enabled = true
#
						## King cannot castle through checked tile
						#if active_piece.data.type.name == "King":
							#if branch.direction == Constants.Direction.EAST:
								#active_piece.data.set_meta("is_castling_kingside_valid", false)
							#elif branch.direction == Constants.Direction.WEST:
								#active_piece.data.set_meta("is_castling_queenside_valid", false)
#
			#if branch.is_castling:
				#var king_tile: TileObject = selected_tile
#
				#if (	active_piece.data.flag.has_moved.enabled # if king has moved
						#or active_piece.data.flag.is_checked.enabled # if king is in check
						#or (	branch.direction == Constants.Direction.EAST
								#and not active_piece.data.get_meta("is_castling_kingside_valid"))	# if east tile is checked
						#or (	branch.direction == Constants.Direction.WEST
								#and not active_piece.data.get_meta("is_castling_queenside_valid")) # if west tile is checked
						#):
					#break
#
				## Get rook tile for current castling side
				#var rook_tile: TileObject
				#if current_tile_ptr.data.position_vector > king_tile.data.position_vector:
					#rook_tile = data.tile_array[Match.get_board_index(king_tile.data.rank,data.file_count-1)]
				#elif current_tile_ptr.data.position_vector < king_tile.data.position_vector:
					#rook_tile = data.tile_array[Match.get_board_index(king_tile.data.rank,0)]
#
				#if (	not rook_tile.is_occupied # if no occupant
						#or not rook_tile.occupant.is_in_group("Rook") # if occupant is not a rook
						#or rook_tile.occupant_data.flag.has_moved.enabled # if rook has moved
						#):
					#break
#
				## equation gives either 1 or -1
				#var range_increment_direction:int = (
						#(rook_tile.data.file - king_tile.data.file)
						#/ abs(rook_tile.data.file - king_tile.data.file)
						#)
#
				#var is_empty_between_pieces: bool = true
				#for tile_file in range(king_tile.data.file + range_increment_direction, rook_tile.data.file, range_increment_direction):
					#if data.tile_array[Match.get_board_index(king_tile.data.rank,tile_file)].occupant:
						#is_empty_between_pieces = false
#
				#if not is_empty_between_pieces: # tiles between rook and king are occupied
					#break
#
				#if data.legal_moves.contains_move([data.tile_array[active_piece.data.index], current_tile_ptr]):
					#rook_tile.occupant_data.flag.is_castling.enabled = true
					#current_tile_ptr.data.change("is_castling",true)
#
			#distance -= 1
#
		#if branch.is_branching and distance == 0:
			#resolve_branching_movement(active_piece, branch, current_tile_ptr)
#
#
#func _capture_piece(piece) -> void:
	#piece._captured()
	#audio_piece_capture.play()
#
#
#func _perform_move(move: Move):
	#get_tree().notify_group("Tile",TileObject.NOTIFICATION_CLEAR_CHECK_STATE)
	#get_tree().notify_group("Tile",TileObject.NOTIFICATION_CLEAR_OTHER_STATES)
	#var piece: PieceObject = move.starting_tile.occupant
	#move.starting_tile.occupant = null
#
	#piece.move_to(move.destination_tile)
	#audio_piece_move.play()
#
	#if not piece.data.flag.has_moved.enabled:
		#piece.moved(true)
#
	#TileModifier.apply_on_piece_enter(move) # used for poison, kings favor, smokey, and button
	#_apply_on_piece_pass(move) # used only for lever
#
	## match occupants in piece_array to their respective tiles in tile_array
	#for tile in data.tile_array:
		#data.piece_array[tile.data.index] = tile.occupant
#
	## determine if check or checkmate has occured
	#var opponent_moves:= MoveList.new(data)
	#opponent_moves.generate_legal_moves(Match.get_opponent_of(Player.current))
	#if opponent_moves.moves.is_empty():
		#move.outcome_flag.checkmate.enabled = true
		#Match.game_overlay.show_checkmate(Player.current)
#
#
	#detect_check(Match.get_opponent_of(Player.current))
	#if not opponent_moves.moves.is_empty() and Match.get_opponent_of(Player.current).pieces["King"][0].data.flag.is_checked.enabled:
		#move.outcome_flag.check.enabled = true
#
	#if piece.data.type.can_promote and move.destination_tile.data.rank == piece.data.player.promotion_rank:
		#move.outcome_flag.promotion.enabled = true
		#Match.is_promotion_occuring = true
		#promotion_verified.emit(piece)
#
	#if not piece.data.flag.has_moved.enabled:
		#piece.moved(true)
#
	#if AlgebraicNotaion.get_notation(move) != "": # empty string due to castling move
		#if move.outcome_flag.promotion.enabled:
			#move._notation_suffix += piece.data.type.algebraic_notation
		#Match.move_history.append(AlgebraicNotaion.get_notation(move))
#
#
### Sets up the next turn
#func next_turn() -> void:
	#_apply_turn_end_modifiers()
	#_update_modifier_lifetimes()
#
	## increments the turn number
	#Match.turn_num += 1
#
	#Player.previous = Player.current
	#Player.current = Match.get_opponent_of(Player.previous)
#
	#turn_changed.emit()
#
	#if Player.current == Player.en_passant:
		## clear en passant
		#PieceObject.en_passant = null
		#TileObject.en_passant = null
#
	#_update_poisoned_pieces()
	#_update_smokey_visuals()
#
	#data.legal_moves.generate_legal_moves(Player.current)
#
	#if Match.is_timed and NetworkManager.is_online:
		#NetworkSync.timer_start.rpc(Time.get_unix_time_from_system())

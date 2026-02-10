extends GameNode3D

signal next_turn(player: int)
signal promotion_requested(piece)

const TURN_TRANSITION_DELAY_MSEC:int = 500
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = USER_SETTING.CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC

var time_turn_ended:int = 0
var time_elapsed_since_turn_ended = 0
var turn_num: int = 0
var current_player_turn: Player = Player.PLAYER_ONE
var previous_player_turn: Player = Player.PLAYER_ONE

var selected_piece: Node3D = null
var selected_piece_tile: Node3D = null

var en_passant_player:Player
var en_passant_tile: Node3D = null
var en_passant_piece: Node3D = null

@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move


var legal_moves: Array

var board_array: Array

var piece_location: Array


var neighboring_tiles: Dictionary[Direction, Vector2i] = {
	Direction.NORTH: Vector2i(-1,0),
	Direction.NORTHEAST: Vector2i(-1,1),
	Direction.EAST: Vector2i(0,1),
	Direction.SOUTHEAST: Vector2i(1,1),
	Direction.SOUTH: Vector2i(1,0),
	Direction.SOUTHWEST: Vector2i(1,-1),
	Direction.WEST: Vector2i(0,-1),
	Direction.NORTHWEST: Vector2i(-1,-1)
}


func _process(delta: float) -> void:
	if previous_player_turn != current_player_turn:
		if time_turn_ended == 0:
			time_turn_ended = Time.get_ticks_msec()
			
		time_elapsed_since_turn_ended = Time.get_ticks_msec() - time_turn_ended - TURN_TRANSITION_DELAY_MSEC
		if time_elapsed_since_turn_ended > 0:
			if time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED < 1:
				%BoardBase.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[previous_player_turn].lerp(COLOR_PALETTE.PLAYER_COLOR[current_player_turn],time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED)
			elif time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED >= 1:
				previous_player_turn = current_player_turn
				time_turn_ended = 0
				time_elapsed_since_turn_ended = 0
				%BoardBase.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[current_player_turn]


func _on_ready() -> void:
	create_board()
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))
	legal_moves = _generate_legal_moves()
	
	
func _create_2d_array(length:int, width:int):
	var empty_array: Array = []
	empty_array.resize(length)
	for index in range(length):
		empty_array[index] = []
		empty_array[index].resize(width)
	return empty_array


func create_board():
	board_array = _create_2d_array(BOARD_LENGTH,BOARD_WIDTH)
	piece_location = _create_2d_array(BOARD_LENGTH,BOARD_WIDTH)
	
	for tile in get_tree().get_nodes_in_group("Tile"):
		board_array[tile.board_position.x][tile.board_position.y] = tile
		piece_location[tile.board_position.x][tile.board_position.y] = tile.occupant
	#Global.print_better(piece_location)
	#Global.print_better(board_array)


func _get_tile_from_piece(piece):
	for row in range(BOARD_LENGTH):
		for column in range(BOARD_WIDTH):
			if piece_location[row][column] == piece:
				return board_array[row][column]


func _generate_moves_from_piece(piece):
	var moveset = MoveRule.new(ActionType.BRANCH, PurposeType.GENERATE_ALL_MOVES,0,0,piece.move_rules).new_duplicate()
	var full_movement = []
	
	if moveset.distance == 0 and moveset.action_flag_is_enabled(ActionType.BRANCH):
		var moves = resolve_branching_movement(piece, moveset, _get_tile_from_piece(piece))
		while ([] in moves):
			moves.erase([])
		return moves


func _generate_all_moves(player: Player):
	var moves: Array = []
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.occupant and tile.occupant in get_tree().get_nodes_in_group(player_groups[player]):
			moves.append_array(_generate_moves_from_piece(tile.occupant))
	return moves
	
	
func _make_virtual_move(move: Array):
	var starting_tile = move[0]
	var destination_tile = move[1]
	
	destination_tile.occupant = starting_tile.occupant
	starting_tile.occupant = null


func _unmake_virtual_move(move: Array):
	var starting_tile = move[0]
	var destination_tile = move[1]
	
	starting_tile.occupant = destination_tile.occupant
	destination_tile.occupant = piece_location[destination_tile.board_position.x][destination_tile.board_position.y]
	
	
func _get_opponent_of(player: Player):
	if player == Player.PLAYER_ONE:
		return Player.PLAYER_TWO
	elif player == Player.PLAYER_TWO:
		return Player.PLAYER_ONE
	
	
func _get_king_of(player: Player):
	for piece in get_tree().get_nodes_in_group(player_groups[player]):
		if piece.is_in_group("King"):
			return piece

func _is_move_legal(move: Array):
	var is_legal:bool = true
	_make_virtual_move(move)
	
	var opponent_moves = _generate_all_moves(_get_opponent_of(current_player_turn))
	for opposing_move in opponent_moves:
		if opposing_move and opposing_move[1].occupant == _get_king_of(current_player_turn):
			is_legal = false
			break
	
	_unmake_virtual_move(move)
	
	if is_legal:
		return true
	
	
	
func _generate_legal_moves():
	var pseudo_legal_moves = _generate_all_moves(current_player_turn)
	var legal_movement = []

	for move in pseudo_legal_moves:
		var is_legal:bool = true
		_make_virtual_move(move)
		
		var opponent_moves = _generate_all_moves(_get_opponent_of(current_player_turn))
		for opposing_move in opponent_moves:
			if opposing_move and opposing_move[1].occupant == _get_king_of(current_player_turn):
				is_legal = false
				break
		
		if is_legal:
			legal_movement.append(move)
		
		_unmake_virtual_move(move)
	return legal_movement

func _on_tile_clicked(clicked_tile: Node3D):
		
	if selected_piece and selected_piece_tile: # piece is already selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			# Clicked tile and selected tile are the same
			if selected_piece == clicked_tile.occupant and selected_piece_tile == clicked_tile:
				_unselect_tile()
			# occupant piece belongs to current player
			elif clicked_tile.occupant.is_in_group(player_groups[current_player_turn]):
				_unselect_tile()
				clear_movement()
				_select_tile(clicked_tile)
			# occupant piece belongs to different player
			elif not clicked_tile.occupant.is_in_group(player_groups[current_player_turn]):
				if clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED):
					capture_piece(clicked_tile.occupant)
					move_piece_to_tile(selected_piece,clicked_tile)
					_next_turn()
		elif clicked_tile.occupant == null:
			if clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.MOVEMENT):
				if selected_piece.is_in_group("Pawn") and not selected_piece.is_in_group("has_moved") and abs(clicked_tile.board_position - selected_piece_tile.board_position) == Vector2i(2,0):
					_set_en_passant(clicked_tile)
				move_piece_to_tile(selected_piece,clicked_tile)
				_next_turn()
			elif clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.SPECIAL):
				move_piece_to_tile(selected_piece,clicked_tile)
				perform_castling_move(clicked_tile) # castling
				_next_turn()
			elif clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED):
				if en_passant_tile and clicked_tile == en_passant_tile:
					if en_passant_piece and not en_passant_piece.is_in_group(player_groups[current_player_turn]):
						capture_piece(en_passant_piece)
						move_piece_to_tile(selected_piece,clicked_tile)
						_next_turn()
			
	elif selected_piece == null: # no piece selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			if clicked_tile.occupant.is_in_group(player_groups[current_player_turn]): # occupant piece belongs to current player
				_select_tile(clicked_tile)


func _set_en_passant(clicked_tile: Node3D):
	en_passant_piece = selected_piece
	var en_passant_tile_x = selected_piece_tile.board_position.x + (clicked_tile.board_position.x - selected_piece_tile.board_position.x)/2
	var en_passant_tile_y = selected_piece_tile.board_position.y
	en_passant_tile = board_array[en_passant_tile_x][en_passant_tile_y]
	en_passant_player = current_player_turn


func _clear_en_passant():
	en_passant_piece = null
	en_passant_tile = null


func _select_tile(tile: Node3D):
	selected_piece_tile = tile
	selected_piece = tile.occupant
	selected_piece_tile._select()
	show_valid_piece_movement()
	if selected_piece.is_in_group("King") and not selected_piece.is_in_group("has_moved"):
		show_valid_castling_movement()


func _unselect_tile():
	selected_piece_tile._unselect()
	selected_piece_tile = null
	selected_piece = null
	clear_movement()


func show_valid_castling_movement():
	var king_tile = selected_piece_tile
	
	var corner_tiles = [
		board_array[selected_piece_tile.board_position.x][0],
		board_array[selected_piece_tile.board_position.x][BOARD_WIDTH-1]
	]
	
	# Check if corner tiles are occupied by unmoved rooks
	var proceed: bool = true

	for tile in corner_tiles:
		if tile.occupant and tile.occupant.is_in_group("Rook") and not tile.occupant.is_in_group("has_moved"):
			# Check if tiles between king and rook are not occupied
			var step = 1 if tile.board_position > king_tile.board_position else -1
			proceed = true
			for tile_column_position in range(king_tile.board_position.y, tile.board_position.y, step):
				if board_array[king_tile.board_position.x][tile_column_position] == king_tile:
					if king_tile.tile_state(Flag.is_enabled_func, TileStateFlag.CHECKED):
						proceed = false
						break
					else:
						continue
				elif board_array[king_tile.board_position.x][tile_column_position].occupant:
					proceed = false
					break
				elif abs(tile_column_position - king_tile.board_position.y) <= 2 and not _is_move_legal([king_tile,board_array[king_tile.board_position.x][tile_column_position]]):
					proceed = false
					break
				
			var castling_tile = null
			
			if proceed and tile.board_position > king_tile.board_position:
				castling_tile = board_array[selected_piece_tile.board_position.x][king_tile.board_position.y + 2]
			elif proceed and tile.board_position < king_tile.board_position:
				castling_tile = board_array[selected_piece_tile.board_position.x][king_tile.board_position.y - 2]
			
			if castling_tile:
				castling_tile._show_castling()
				tile.occupant._show_castling()


func perform_castling_move(castling_tile: Node3D):
	if castling_tile.board_position.y > (BOARD_WIDTH/2) - 1:
		var castling_rook = board_array[castling_tile.board_position.x][BOARD_WIDTH-1].occupant
		var castling_rook_destination = board_array[castling_tile.board_position.x][castling_tile.board_position.y-1]
		move_piece_to_tile(castling_rook, castling_rook_destination)
	elif castling_tile.board_position.y < (BOARD_WIDTH/2) - 1:
		var castling_rook = board_array[castling_tile.board_position.x][0].occupant
		var castling_rook_destination = board_array[castling_tile.board_position.x][castling_tile.board_position.y+1]
		move_piece_to_tile(castling_rook, castling_rook_destination)

				
func detect_check():
	var player_king = _get_king_of(current_player_turn)
	var player_king_tile = _get_tile_from_piece(player_king)
	
	var opponent_moves = _generate_all_moves(_get_opponent_of(current_player_turn))
	
	for move in opponent_moves:
		if move[1].occupant and move[1].occupant.is_in_group("King") and move[1].occupant.is_in_group(player_groups[current_player_turn]):
			player_king_tile._set_check()
			break
	
func clear_check():
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.tile_state(Flag.is_enabled_func, TileStateFlag.CHECKED):
			tile._unset_check()
	
func show_valid_piece_movement():
	var moveset = MoveRule.new(ActionType.BRANCH, PurposeType.STANDARD_MOVEMENT,0,0,selected_piece.move_rules).new_duplicate()
	
	if moveset.distance == 0 and moveset.action_flag_is_enabled(ActionType.BRANCH):
		resolve_branching_movement(selected_piece, moveset, selected_piece_tile)
		
		
func resolve_branching_movement(active_piece:Piece, moveset: MoveRule, origin_tile: Node3D):
	var movements = []
	
	for branch in moveset.branches:
		var current_tile_ptr = origin_tile
		
		branch.purpose = moveset.purpose
		while branch.distance > 0:
			if current_tile_ptr == null:
				break
			
			if (current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x > BOARD_LENGTH-1 
					or current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x < 0
					or current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y > BOARD_WIDTH-1
					or current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y < 0):
				break
			else:
				current_tile_ptr = board_array[current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x][current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y]
			
			if active_piece.is_in_group("Knight"):
				pass
			
			if current_tile_ptr: # current_tile_ptr exists
				if current_tile_ptr.occupant: # current_tile_ptr is occupied
					if active_piece.player != current_tile_ptr.occupant.player: # current_tile_ptr is occupied by opponent piece
						if branch.action_flag_is_enabled(ActionType.THREATEN):
							#region Tile can be Threatened
							if moveset.purpose == PurposeType.STANDARD_MOVEMENT:
								current_tile_ptr._threaten()
								break
							elif moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
								movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
								break				
							#endregion
					if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
						if not branch.action_flag_is_enabled(ActionType.JUMP):
							#region Tile is Blocked
							if moveset.purpose == PurposeType.STANDARD_MOVEMENT:
								break 
							elif moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
								break
							#endregion
				elif current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					if current_tile_ptr == en_passant_tile:
						#region En Passant
						if moveset.purpose == PurposeType.STANDARD_MOVEMENT:
							if active_piece.player != en_passant_piece.player:
								if branch.action_flag_is_enabled(ActionType.THREATEN):
									en_passant_tile._threaten()
									en_passant_piece._threaten()
						elif moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
							movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
						#endregion
					elif branch.action_flag_is_enabled(ActionType.MOVE):
						#region Tile is empty
						if moveset.purpose == PurposeType.STANDARD_MOVEMENT:
							var legal:bool = false
							for move in legal_moves:
								if move == [_get_tile_from_piece(active_piece), current_tile_ptr]:
									legal = true
							if legal:
								current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.MOVEMENT)
							else:
								current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.CHECKED_MOVEMENT)
							
						elif moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
							movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
						#endregion

				branch.distance -= 1
			
		if branch.distance == 0 and branch.action_flag_is_enabled(ActionType.BRANCH):
			if moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
				movements.append_array(resolve_branching_movement(active_piece, branch, current_tile_ptr))
			elif moveset.purpose == PurposeType.STANDARD_MOVEMENT:
				resolve_branching_movement(active_piece, branch, current_tile_ptr)
	
	if moveset.purpose == PurposeType.GENERATE_ALL_MOVES:
		return movements

func capture_piece(piece):
	piece.translate(Vector3(0,-5,0))
	piece.reparent(%Captured)
	piece._captured()
	piece_capture_audio.play()


func move_piece_to_tile(piece: Node3D, tile: Node3D):
	clear_check()
	
	#if piece.is_in_group("Pawn"):
		#if piece.is_in_group("Player_One") and tile.board_postion.y == BOARD_LENGTH-1:
			#piece.promote()
			#piece.remove_from_group("Pawn")
			#
		#if piece.is_in_group("Player_Two") and tile.board_postion.y == 0:
			#piece.remove_from_group("Pawn")
	
	selected_piece_tile._unselect()
	clear_movement()
	selected_piece_tile.occupant = null
	
	tile.occupant = piece
	piece.reparent(tile)
	piece.global_position = (
			tile.global_position * Vector3(1,0,1)
			+ piece.global_position * Vector3(0,1,0)
	)
	piece_move_audio.play()
	
	if not piece.is_in_group("has_moved"):
		piece.add_to_group("has_moved")
		piece.moved()
	if selected_piece == piece:
		selected_piece = null

	
func clear_movement():
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.tile_state(Flag.unset_func, TileStateFlag.MOVEMENT)
		tile.tile_state(Flag.unset_func, TileStateFlag.CHECKED_MOVEMENT)
		tile._unthreaten()
		tile._hide_castling()
	
		
## Sets up the next turn
func _next_turn() -> void:
	
	for tile in get_tree().get_nodes_in_group("Tile"):
		piece_location[tile.board_position.x][tile.board_position.y] = tile.occupant
	
	# increments the turn number
	turn_num += 1
	previous_player_turn = current_player_turn
	current_player_turn = _get_opponent_of(previous_player_turn)
	
	if current_player_turn == en_passant_player:
		_clear_en_passant()
	
	legal_moves = _generate_legal_moves()
	if legal_moves.is_empty():
		pass # Checkmate
	else:
		detect_check()

	next_turn.emit()








	#var proceed = true
	#
	#if modifier_order.size() > 0:
		#proceed = _apply_modifiers()

#func _apply_modifiers():
	#var slide_direction: Direction = _moveset.direction
#
	#for modifier in modifier_order:
		#match modifier.flag:
			#TileModifierFlag.PROPERTY_COG:
				#if modifier.rotation == modifier.Rotation.CLOCKWISE:
					#_moveset.call_func_on_moves(Callable(_moveset,"rotate_clockwise"))
				#elif modifier.rotation == modifier.Rotation.COUNTERCLOCKWISE:
					#_moveset.call_func_on_moves(Callable(_moveset,"rotate_counterclockwise"))
			#TileModifierFlag.CONDITION_STICKY:
				## Prevents the piece from moving further, 
				## but doesn't prevent movement if the piece is occupying the tile
				#_moveset.distance = 0	
			#TileModifierFlag.CONDITION_ICY:
				#var neighboring_tile_occupant = neighboring_tiles[_moveset.direction].occupant
				#if ( 	not _moving_piece.is_in_group("Knight")
						#and neighboring_tiles[_moveset.direction] 
						#and (
								#not neighboring_tile_occupant
								#or _moving_piece.is_opponent_to(neighboring_tile_occupant)
								#)
						#and _moving_piece == occupant
						#):
					#_connect_to_neighboring_tile(_moveset, slide_direction)
					#return false
			#TileModifierFlag.PROPERTY_CONVEYER:
				#_connect_to_neighboring_tile(_moveset, modifier.direction)
				#return false
			#TileModifierFlag.PROPERTY_PRISM:
				#pass
	#return true










		
func change_piece_resources(old_piece: Node3D, new_piece: PieceType):
	old_piece.find_child("Piece_Mesh").mesh = PIECE_MESH[new_piece]
	old_piece.set_script(PIECE_SCRIPT[new_piece])

func promote(piece:Piece, promotion: PawnPromotion):
	var piece_player = piece.player
	
	match promotion:
		PawnPromotion.ROOK:
			change_piece_resources(piece,PieceType.ROOK)
			piece.add_to_group("Rook")
		PawnPromotion.BISHOP: 
			change_piece_resources(piece,PieceType.BISHOP)
			piece.add_to_group("Bishop")
		PawnPromotion.KNIGHT:
			change_piece_resources(piece,PieceType.KNIGHT)
			piece.add_to_group("Knight")
		PawnPromotion.QUEEN:
			change_piece_resources(piece,PieceType.QUEEN)
			piece.add_to_group("Queen")
	
	piece.player = piece_player
	piece.ready.emit()

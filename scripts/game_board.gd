extends GameNode3D


signal promotion_requested(piece)

const BOARD_TURN_TRANSITION_DELAY_MSEC:int = 500
var time_turn_ended:int = 0
var time_elapsed_since_turn_ended = 0
static var turn_num: int = 0
static var current_player_turn: Player = Player.PLAYER_ONE
static var previous_player_turn: Player = Player.PLAYER_ONE

var selected_piece: Node3D
var selected_piece_tile: Node3D


@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move


signal next_turn(player: int)


var board_array = []


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
			
		time_elapsed_since_turn_ended = Time.get_ticks_msec() - time_turn_ended
		
		if time_elapsed_since_turn_ended/BOARD_TURN_TRANSITION_DELAY_MSEC < 1:
			%BoardBase.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[previous_player_turn].lerp(COLOR_PALETTE.PLAYER_COLOR[current_player_turn],time_elapsed_since_turn_ended/BOARD_TURN_TRANSITION_DELAY_MSEC)
		elif time_elapsed_since_turn_ended/BOARD_TURN_TRANSITION_DELAY_MSEC >= 1:
			previous_player_turn = current_player_turn
			time_turn_ended = 0
			time_elapsed_since_turn_ended = 0
			%BoardBase.get_surface_override_material(0).albedo_color = COLOR_PALETTE.PLAYER_COLOR[current_player_turn]


func _on_ready() -> void:
	create_board()
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))
	
	
func create_board():
	board_array.resize(BOARD_LENGTH)
	
	for index in range(BOARD_LENGTH):
		board_array[index] = []
		board_array[index].resize(BOARD_WIDTH)
	
	for tile in get_tree().get_nodes_in_group("Tile"):
		board_array[tile.board_position.x][tile.board_position.y] = tile
	#Global.print_better(board_array)


func _on_tile_clicked(tile: Node3D):
	if selected_piece and selected_piece_tile: # piece is already selected
		if tile.tile_occupant: # Clicked Tile is occupied
			if selected_piece == tile.tile_occupant and selected_piece_tile == tile: # Clicked tile and selected tile are the same
				_unselect_tile()
			elif tile.tile_occupant.is_in_group(player_groups[current_player_turn]): # occupant piece belongs to current player
				_unselect_tile()
				clear_movement()
				_select_tile(tile)
			elif not tile.tile_occupant.is_in_group(player_groups[current_player_turn]): # occupant piece belongs to different player
				if tile.tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED):
					capture_piece(tile.tile_occupant)
					move_piece_to_tile(selected_piece,tile)
				pass # capture piece
		elif tile.tile_occupant == null:
			move_piece_to_tile(selected_piece,tile) # move selected piece to clicked tile
	elif selected_piece == null: # no piece selected
		if tile.tile_occupant: # Clicked Tile is occupied
			if tile.tile_occupant.is_in_group(player_groups[current_player_turn]): # occupant piece belongs to current player
				_select_tile(tile)


func _select_tile(tile: Node3D):
	selected_piece_tile = tile
	selected_piece = tile.tile_occupant
	selected_piece_tile._select()
	show_valid_piece_movement()


func _unselect_tile():
	selected_piece_tile._unselect()
	selected_piece_tile = null
	selected_piece = null
	clear_movement()

			
func show_valid_piece_movement():
	var moveset = MoveRule.new(ActionType.BRANCH, PurposeType.STANDARD_MOVEMENT,0,0,selected_piece.move_rules).new_duplicate()
	var current_tile_ptr = selected_piece_tile
	
	if moveset.distance == 0 and moveset.action_flag_is_enabled(ActionType.BRANCH):
		resolve_branching_movement(moveset, current_tile_ptr)
	
func resolve_branching_movement(moveset: MoveRule, origin_tile: Node3D):
	for branch in moveset.branches:
		var current_tile_ptr = origin_tile
		branch.purpose = moveset.purpose
		while branch.distance > 0:
			if current_tile_ptr == null:
				break
			current_tile_ptr = get_tile_at_position(
					current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x,
					current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y 
			)
			if current_tile_ptr:
				if current_tile_ptr.tile_occupant:
					if selected_piece.player != current_tile_ptr.tile_occupant.player:
						if branch.action_flag_is_enabled(ActionType.THREATEN):
							current_tile_ptr._threaten()
							break
					if selected_piece != current_tile_ptr.tile_occupant:
						if not branch.action_flag_is_enabled(ActionType.JUMP):
							break
				elif current_tile_ptr.tile_occupant == null:
					if branch.action_flag_is_enabled(ActionType.MOVE):
						current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.MOVEMENT)

				branch.distance -= 1

					#if selected_piece and selected_piece.is_in_group("King") and current_tile_ptr._checked_by.is_empty():
						#current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.THREATENED)
				#
				#
				#if selected_piece.is_threatened_by_en_passant(current_tile_ptr.board_position):
					#current_tile_ptr.en_passant_occupant = selected_piece
				#
				#if selected_piece.is_threat_to_en_passant_piece(moveset, current_tile_ptr.en_passant_occupant):
					#current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.THREATENED)
					#current_tile_ptr.en_passant_occupant.piece_state(Flag.set_func, PieceStateFlag.THREATENED)
			
		if moveset.distance == 0 and moveset.action_flag_is_enabled(ActionType.BRANCH):
			resolve_branching_movement(branch,current_tile_ptr)
		else:
			return

	
func get_tile_at_position(row: int, column: int) -> Node3D:
	if (row >= BOARD_LENGTH or row < 0 or column >= BOARD_WIDTH or column < 0):
		return null
	elif board_array[row][column]:
		return board_array[row][column]
	else:
		return null

func capture_piece(piece):
	piece.piece_state(Flag.set_func, PieceStateFlag.CAPTURED)
	piece_capture_audio.play()
		
func move_piece_to_tile(piece: Node3D, tile: Node3D):
	selected_piece_tile._unselect()
	clear_movement()
	selected_piece_tile.tile_occupant = null
	
	tile.tile_occupant = selected_piece
	selected_piece.reparent(tile)
	selected_piece.global_position = (
			tile.global_position * Vector3(1,0,1)
			+ selected_piece.global_position * Vector3(0,1,0)
	)
	piece_move_audio.play()
	
	if not selected_piece.is_in_group("has_moved"):
		selected_piece.add_to_group("has_moved")
		selected_piece.call("moved")
	
	selected_piece = null
	_next_turn()
	
func clear_movement():
	for row in board_array:
		for tile in row:
			tile.tile_state(Flag.unset_func, TileStateFlag.MOVEMENT)
			tile._unthreaten()
			tile.tile_state(Flag.unset_func, TileStateFlag.SPECIAL)
	
	
	
## Sets up the next turn
func _next_turn() -> void:
	# Discover if king is still in check
	#for piece in get_tree().get_nodes_in_group(player_groups[(current_player_turn+1)%2]):
		#piece.get_parent().discover_checks()
	#
	## Clear previous checks
	#get_tree().call_group("Tile","_clear_checks")
	#
	## Discover which pieces check which tiles
	#for piece in get_tree().get_nodes_in_group(player_groups[current_player_turn]):
		#piece.get_parent().discover_checks()
	
	# increments the turn number
	turn_num += 1
	previous_player_turn = current_player_turn
	current_player_turn = ((current_player_turn + 1) % 2 ) as Player
	
	#get_tree().call_group("Tile","_clear_castling_occupant")
	#get_tree().call_group("Tile","_clear_en_passant",current_player_turn)
	next_turn.emit()















	#var proceed = true
	#
	#if modifier_order.size() > 0:
		#proceed = _apply_modifiers()
	#
	#if proceed:
		#if _moveset.distance > 0:
			#_moveset.distance -= 1
		##DETERMINE TILE STATE FROM MOVES	
		#if _moveset.purpose == PurposeType.CHECK_DETECTING:
			#proceed = _perform_check_detection()
			#
			#
		#elif _moveset.purpose == PurposeType.CASTLING and _moveset.action_flag_is_enabled(ActionType.JUMP):
			#proceed = _perform_castling(castling_rook)
				#
		#elif _moveset.purpose == PurposeType.ROOK_FINDING:
			#proceed = _perform_rook_finding()
			#
		#else:
			#proceed = _perform_show_movement()
			#
	##SEND MOVES TO NEIGHBORING TILES
	#if proceed:
		#if _moveset.distance == 0 and _moveset.action_flag_is_enabled(ActionType.BRANCH):
			#for branching_move in _moveset.branches:
				#branching_move.purpose = _moveset.purpose
				#if neighboring_tiles[branching_move.direction]:
					#_connect_to_neighboring_tile(branching_move, branching_move.direction, castling_rook)
		#elif _moveset.distance > 0:
			#_connect_to_neighboring_tile(_moveset, _moveset.direction, castling_rook)
#
#
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
				#var neighboring_tile_occupant = neighboring_tiles[_moveset.direction].tile_occupant
				#if ( 	not _moving_piece.is_in_group("Knight")
						#and neighboring_tiles[_moveset.direction] 
						#and (
								#not neighboring_tile_occupant
								#or _moving_piece.is_opponent_to(neighboring_tile_occupant)
								#)
						#and _moving_piece == tile_occupant
						#):
					#_connect_to_neighboring_tile(_moveset, slide_direction)
					#return false
			#TileModifierFlag.PROPERTY_CONVEYER:
				#_connect_to_neighboring_tile(_moveset, modifier.direction)
				#return false
			#TileModifierFlag.PROPERTY_PRISM:
				#pass
	#return true
#
#
#func _perform_check_detection():
	#if _moveset.action_flag_is_enabled(ActionType.THREATEN):
		#_checked_by.append(_moving_piece)
		#
		#if _moving_piece.is_opponent_to(tile_occupant):	
			#if tile_occupant and not tile_occupant.is_in_group("King"): 
				#return false
			#if tile_occupant.piece_state(Flag.is_enabled_func, PieceStateFlag.CHECKED):
				#print("END GAME")
			#tile_state(Flag.set_func, TileStateFlag.CHECKED)
			#tile_occupant.piece_state(Flag.set_func, PieceStateFlag.CHECKED)
			#return false
	#return true
#
#
#func _perform_castling(castling_rook: Piece):
	#if _checked_by: 
		#return false
		#
	#if _moveset.action_flag_is_enabled(ActionType.SPECIAL) and _moveset.distance == 0:
		#tile_state(Flag.set_func, TileStateFlag.SPECIAL)
		#return false
	#
	#_castling_occupant = castling_rook
	#_castling_occupant.piece_state(Flag.set_func, PieceStateFlag.SPECIAL)
	#_toggle_rook_castling_tile_connection(_moveset)
	#return true
#
#
#func _perform_rook_finding():
	#if tile_occupant and _moving_piece != tile_occupant:
		#if _moving_piece.is_valid_castling_rook(tile_occupant):
			#_send_to_king(_moving_piece, tile_occupant, _moveset.direction)
		#return false
	#return true








func _on_tile_selected(tile: Node3D) -> void:
	if tile.tile_occupant == selected_piece:
		selected_piece_tile = tile 

	var proceed = true
	if selected_piece.is_in_group("Pawn") and tile.en_passant_occupant and tile.en_passant_occupant != selected_piece:
		tile.en_passant_occupant.piece_state(Flag.set_func, PieceStateFlag.CAPTURED)
		piece_capture_audio.play()
	else:
		piece_move_audio.play()

	
	if tile.tile_state(Flag.is_enabled_func, TileStateFlag.SPECIAL):
		var castling_king = selected_piece
		tile.castle.emit()
		proceed = false
		selected_piece = castling_king
	
	
	if selected_piece.is_in_group("Pawn"):
		if selected_piece.is_in_group("Player_One") and not tile.neighboring_tiles[Direction.SOUTH]:
			selected_piece.remove_from_group("Pawn")
			promotion_requested.emit(selected_piece)
			
		if selected_piece.is_in_group("Player_Two") and not tile.neighboring_tiles[Direction.NORTH]:
			selected_piece.remove_from_group("Pawn")
			promotion_requested.emit(selected_piece)
		
		



func change_piece_resources(old_piece: Node3D, new_piece: PieceType):
	old_piece.find_child("Piece_Mesh").mesh = PIECE_MESH[new_piece]
	old_piece.find_child("Outline").mesh = PIECE_MESH[new_piece]
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

extends GameNode3D


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
var selected_castling_rook_tile: Node3D = null

var en_passant_player:Player
var en_passant_tile: Node3D = null
var en_passant_piece: Node3D = null

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
	
	if NetworkManager.is_online:
		NetworkManager.opponent_disconnected.connect(_on_opponent_disconnected)
	
	
func create_board():
	board_array.resize(BOARD_LENGTH)
	
	for index in range(BOARD_LENGTH):
		board_array[index] = []
		board_array[index].resize(BOARD_WIDTH)
	
	for tile in get_tree().get_nodes_in_group("Tile"):
		board_array[tile.board_position.x][tile.board_position.y] = tile
	#Global.print_better(board_array)


func _on_tile_clicked(clicked_tile: Node3D):
	print("TEST")
	if not NetworkManager.is_my_turn(current_player_turn):
		return
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
					#capture_piece(clicked_tile.occupant)
					#move_piece_to_tile(selected_piece,clicked_tile)
					#_next_turn()
					_sync_move.rpc(selected_piece_tile.board_position, clicked_tile.board_position, false)
		elif clicked_tile.occupant == null:
			if clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.MOVEMENT):
				_next_turn()
				_sync_move.rpc(selected_piece_tile.board_position, clicked_tile.board_position, false)
				#if selected_piece.is_in_group("Pawn") and not selected_piece.is_in_group("has_moved") and abs(clicked_tile.board_position - selected_piece_tile.board_position) == Vector2i(2,0):
					#_set_en_passant(clicked_tile)
				#move_piece_to_tile(selected_piece,clicked_tile)
				#_next_turn()
			elif clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.SPECIAL):
				#move_piece_to_tile(selected_piece,clicked_tile)
				#perform_castling_move(clicked_tile) # castling
				#_next_turn()
				_sync_move.rpc(selected_piece_tile.board_position, clicked_tile.board_position, true)
			elif clicked_tile.tile_state(Flag.is_enabled_func, TileStateFlag.THREATENED):
				if en_passant_tile and clicked_tile == en_passant_tile:
					if en_passant_piece and not en_passant_piece.is_in_group(player_groups[current_player_turn]):
						#capture_piece(en_passant_piece)
						#move_piece_to_tile(selected_piece,clicked_tile)
						#_next_turn()
						_sync_move.rpc(selected_piece_tile.board_position, clicked_tile.board_position, false)
						
	elif selected_piece == null: # no piece selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			if clicked_tile.occupant.is_in_group(player_groups[current_player_turn]): # occupant piece belongs to current player
				_select_tile(clicked_tile)

@rpc("any_peer", "call_local", "reliable")
func _sync_move(from: Vector2i, to: Vector2i, is_castling: bool) -> void:
	var from_tile = board_array[from.x][from.y]
	var to_tile   = board_array[to.x][to.y]

	selected_piece_tile = from_tile
	selected_piece = from_tile.occupant

	# Handle en passant
	if selected_piece.is_in_group("Pawn") and not selected_piece.is_in_group("has_moved") and abs(to.x - from.x) == 2:
		_set_en_passant(to_tile)

	# Handle capture
	if to_tile.occupant and to_tile.occupant.player != selected_piece.player:
		capture_piece(to_tile.occupant)
	elif to_tile.occupant == null and en_passant_tile and to_tile == en_passant_tile:
		if en_passant_piece and en_passant_piece.player != selected_piece.player:
			capture_piece(en_passant_piece)

	move_piece_to_tile(selected_piece, to_tile)

	if is_castling:
		perform_castling_move(to_tile)

	_next_turn()

@rpc("any_peer", "call_local", "reliable")
func _sync_promotion(tile_pos: Vector2i, promotion_type: int) -> void:
	var tile = board_array[tile_pos.x][tile_pos.y]
	if tile and tile.occupant:
		promote(tile.occupant, promotion_type as PawnPromotion)

func _on_opponent_disconnected() -> void:
	get_tree().paused = true
	print("Opponent disconnected — game paused.")


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
	var king = selected_piece
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
					continue
				elif board_array[king_tile.board_position.x][tile_column_position].occupant:
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
		move_piece_to_tile(board_array[castling_tile.board_position.x][BOARD_WIDTH-1].occupant, board_array[castling_tile.board_position.x][castling_tile.board_position.y-1])
	elif castling_tile.board_position.y < (BOARD_WIDTH/2) - 1:
		move_piece_to_tile(	board_array[castling_tile.board_position.x][0].occupant, board_array[castling_tile.board_position.x][castling_tile.board_position.y+1])

		
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
			
			if (current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x > BOARD_LENGTH-1 
					or current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x < 0
					or current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y > BOARD_WIDTH-1
					or current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y < 0):
				break
			else:
				current_tile_ptr = board_array[current_tile_ptr.board_position.x + neighboring_tiles[branch.direction].x][current_tile_ptr.board_position.y + neighboring_tiles[branch.direction].y]
			
			if current_tile_ptr:
				if current_tile_ptr.occupant:
					if selected_piece.player != current_tile_ptr.occupant.player:
						if branch.action_flag_is_enabled(ActionType.THREATEN):
							current_tile_ptr._threaten()
							break
					if selected_piece != current_tile_ptr.occupant:
						if not branch.action_flag_is_enabled(ActionType.JUMP):
							break 
				elif current_tile_ptr.occupant == null:
					if current_tile_ptr == en_passant_tile:
						if selected_piece.player != en_passant_piece.player:
							if branch.action_flag_is_enabled(ActionType.THREATEN):
								en_passant_tile._threaten()
								en_passant_piece._threaten()
					elif branch.action_flag_is_enabled(ActionType.MOVE):
						current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.MOVEMENT)

				branch.distance -= 1

			#if selected_piece and selected_piece.is_in_group("King") and current_tile_ptr._checked_by.is_empty():
				#current_tile_ptr.tile_state(Flag.set_func, TileStateFlag.THREATENED)
			
		if moveset.distance == 0 and moveset.action_flag_is_enabled(ActionType.BRANCH):
			resolve_branching_movement(branch,current_tile_ptr)
		else:
			return


func capture_piece(piece):
	piece.translate(Vector3(0,-5,0))
	piece.reparent(%Captured)
	piece._captured()
	piece_capture_audio.play()
		
func move_piece_to_tile(piece: Node3D, tile: Node3D):
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
	for row in board_array:
		for tile in row:
			tile.tile_state(Flag.unset_func, TileStateFlag.MOVEMENT)
			tile._unthreaten()
			tile._hide_castling()
	
	
	
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
	
	if current_player_turn == en_passant_player:
		_clear_en_passant()

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
#
#
#func _perform_check_detection():
	#if _moveset.action_flag_is_enabled(ActionType.THREATEN):
		#_checked_by.append(_moving_piece)
		#
		#if _moving_piece.is_opponent_to(occupant):	
			#if occupant and not occupant.is_in_group("King"): 
				#return false
			#if occupant.piece_state(Flag.is_enabled_func, PieceStateFlag.CHECKED):
				#print("END GAME")
			#tile_state(Flag.set_func, TileStateFlag.CHECKED)
			#occupant.piece_state(Flag.set_func, PieceStateFlag.CHECKED)
			#return false
	#return true

func _on_tile_selected(tile: Node3D) -> void:
	
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

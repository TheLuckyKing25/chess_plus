extends GameNode3D

signal next_turn(player: int)
signal promotion_requested(piece)
signal game_state_changed(game_state: int)

const TURN_TRANSITION_DELAY_MSEC:int = 500
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = USER_SETTING.CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC

const PAWN = preload("res://resources/pieces/pawn/pawn_piece_type.tres")
const BISHOP = preload("res://resources/pieces/bishop/bishop_piece_type.tres")
const ROOK = preload("res://resources/pieces/rook/rook_piece_type.tres")
const KNIGHT = preload("res://resources/pieces/knight/knight_piece_type.tres")
const KING = preload("res://resources/pieces/king/king_piece_type.tres")
const QUEEN = preload("res://resources/pieces/queen/queen_piece_type.tres")


var current_game_state = GameState.BoardCustomization

var time_turn_ended:int = 0
var time_elapsed_since_turn_ended = 0
var turn_num: int = 0

@export var player_one:Player = load("res://resources/players/player_one.tres")
@export var player_two:Player = load("res://resources/players/player_two.tres")

@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move

const TILE_SCENE:PackedScene = preload("res://scenes/tile.tscn")
const PIECE_SCENE:PackedScene = preload("res://scenes/piece/piece.tscn")

var legal_moves: Array

var board_array: Array

var piece_location: Array

var neighboring_tiles: Dictionary[Movement.Direction, Vector2i] = {
	Movement.Direction.NORTH: Vector2i(-1,0),
	Movement.Direction.NORTHEAST: Vector2i(-1,1),
	Movement.Direction.EAST: Vector2i(0,1),
	Movement.Direction.SOUTHEAST: Vector2i(1,1),
	Movement.Direction.SOUTH: Vector2i(1,0),
	Movement.Direction.SOUTHWEST: Vector2i(1,-1),
	Movement.Direction.WEST: Vector2i(0,-1),
	Movement.Direction.NORTHWEST: Vector2i(-1,-1)
}

var num_board_rows: int = 8
var num_board_columns: int = 8

var FEN_piece_layout: String

func _on_gamemode_selection_column_number_changed(value: int) -> void:
	num_board_columns = value


func _on_gamemode_selection_row_number_changed(value: int) -> void:
	num_board_rows = value


func _on_tile_modifier_screen_continue_button_pressed() -> void:
	current_game_state = GameState.Gameplay
	game_state_changed.emit(current_game_state)
	clear_movement()


func _on_game_overlay_new_placement_selected(placement: String) -> void:
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.occupant:
			tile.remove_child(tile.occupant)
			tile.occupant = null
			
	piece_location = _create_array(num_board_rows, num_board_columns)
	
	place_pieces(placement)


func _on_gamemode_selection_continue_button_pressed() -> void:
	generate_board(num_board_columns, num_board_rows)
	place_pieces(FEN_piece_layout)
	current_game_state = GameState.BoardCustomization
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))
	
	
func generate_board(file_num:int, rank_num:int):
	board_array = _create_array(rank_num, file_num)
	piece_location = _create_array(rank_num, file_num)
	
	$BoardBase.mesh.size = Vector3(file_num+1 ,0.2, rank_num+1)
	
	for tile_num in range(file_num * rank_num):
		var new_tile = TILE_SCENE.instantiate()
		new_tile.board_position = get_tile_position_from_index(tile_num)
		new_tile.translate(Vector3(new_tile.rank-(float(rank_num)/2)+0.5, 0.1, new_tile.file-(float(file_num)/2)+0.5))
		$BoardBase.add_child(new_tile,true)	
		board_array[tile_num] = new_tile

func get_index_from_tile_position(file:int,rank:int) -> int:
	return (file * num_board_columns) + (rank)

func get_tile_position_from_index(index:int) -> Vector2i:
	return Vector2i(index/8,index%8)

func place_pieces(FE_notation: String):
	var tile_count = 0
	var new_piece
	for character in FE_notation.split(" ")[0]:
		new_piece = PIECE_SCENE.instantiate()
		match character:
			"p":
				new_piece.stats = PieceStats.new(PAWN, player_two)
			"r":
				new_piece.stats = PieceStats.new(ROOK, player_two)
			"b":
				new_piece.stats = PieceStats.new(BISHOP, player_two)
			"n":
				new_piece.stats = PieceStats.new(KNIGHT, player_two)
			"q":
				new_piece.stats = PieceStats.new(QUEEN, player_two)
			"k":
				new_piece.stats = PieceStats.new(KING, player_two)
			"P":
				new_piece.stats = PieceStats.new(PAWN, player_one)
			"R":
				new_piece.stats = PieceStats.new(ROOK, player_one)
			"B":
				new_piece.stats = PieceStats.new(BISHOP, player_one)
			"N":
				new_piece.stats = PieceStats.new(KNIGHT, player_one)
			"Q":
				new_piece.stats = PieceStats.new(QUEEN, player_one)
			"K":
				new_piece.stats = PieceStats.new(KING, player_one)
			"1","2","3","4","5","6","7","8","9":
				tile_count += character.to_int()
				continue
			_:
				continue
		new_piece.stats.movement.set_max_distance(maxi(num_board_columns,num_board_rows))
		board_array[tile_count].add_child(new_piece,true)
		board_array[tile_count].occupant = new_piece
		piece_location[tile_count] = new_piece
		tile_count += 1
	legal_moves = _generate_legal_moves()

func _on_gamemode_selection_fen_notation_verified(FEN_notation: String) -> void:
	FEN_piece_layout = FEN_notation


func _process(_delta: float) -> void:
	if Player.previous != Player.current:
		if time_turn_ended == 0:
			time_turn_ended = Time.get_ticks_msec()
			
		time_elapsed_since_turn_ended = Time.get_ticks_msec() - time_turn_ended - TURN_TRANSITION_DELAY_MSEC
		if time_elapsed_since_turn_ended > 0:
			if time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED < 1:
				$BoardBase.get_surface_override_material(0).albedo_color = Player.previous.color.lerp(Player.current.color,time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED)
			elif time_elapsed_since_turn_ended * TURN_TRANSITION_SPEED >= 1:
				Player.previous = Player.current
				time_turn_ended = 0
				time_elapsed_since_turn_ended = 0
				$BoardBase.get_surface_override_material(0).albedo_color = Player.current.color


func _on_ready() -> void:
	Player.current = player_one
	Player.previous = player_one

func _create_array(length:int, width:int) -> Array:
	var empty_array: Array = []
	empty_array.resize(length * width)
	return empty_array


func _get_tile_from_piece(piece: Piece):
	for tile_num in range(num_board_rows * num_board_columns):
		if piece_location[tile_num] == piece:
			return board_array[tile_num]


func _generate_moves_from_piece(piece:Piece):
	var moveset:Movement = piece.stats.movement
	moveset.set_purpose_type(Movement.Purpose.GENERATE_ALL_MOVES)
	
	if moveset.distance == 0 and moveset.is_branching:
		var moves = resolve_branching_movement(piece, moveset, _get_tile_from_piece(piece))
		while [] in moves:
			moves.erase([])
		return moves


func _generate_all_moves(player: Player):
	var moves: Array = []
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.occupant and tile.occupant in get_tree().get_nodes_in_group(player.name):
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
	destination_tile.occupant = piece_location[get_index_from_tile_position(destination_tile.file,destination_tile.rank)]


func _get_opponent_of(player: Player):
	if player == player_one:
		return player_two
	elif player == player_two:
		return player_one

func _get_king_of(player: Player):
	for piece in get_tree().get_nodes_in_group(player.name):
		if piece.is_in_group("King"):
			return piece


func _is_move_legal(move: Array):
	var is_legal:bool = true
	_make_virtual_move(move)
	
	var opponent_moves = _generate_all_moves(_get_opponent_of(Player.current))
	for opposing_move in opponent_moves:
		if opposing_move and opposing_move[1].occupant == _get_king_of(Player.current):
			is_legal = false
			break
	
	_unmake_virtual_move(move)
	
	if is_legal:
		return true


func _generate_legal_moves():
	var pseudo_legal_moves = _generate_all_moves(Player.current)
	var legal_movement = []

	for move in pseudo_legal_moves:
		var is_legal:bool = true
		_make_virtual_move(move)
		
		var opponent_moves = _generate_all_moves(_get_opponent_of(Player.current))
		for opposing_move in opponent_moves:
			if opposing_move and opposing_move[1].occupant == _get_king_of(Player.current):
				is_legal = false
				break
		
		if is_legal:
			legal_movement.append(move)
		
		_unmake_virtual_move(move)
	return legal_movement


#region Tile Clicked

func _on_tile_clicked(clicked_tile: Tile):
	if current_game_state == GameState.BoardCustomization:
		_customization_tile_select(clicked_tile)
	elif current_game_state == GameState.Gameplay:	
		_gameplay_tile_select(clicked_tile)

func _customization_tile_select(clicked_tile: Tile):
	if clicked_tile.stats.is_selected == true:
		clicked_tile._unselect()
	elif clicked_tile.stats.is_selected == false:
		clicked_tile._select()

func _gameplay_tile_select(clicked_tile: Tile):
	if Piece.selected and Tile.selected: # piece is already selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			# Clicked tile and selected tile are the same
			if Piece.selected == clicked_tile.occupant and Tile.selected == clicked_tile:
				_unselect_tile()
			# occupant piece belongs to current player
			elif clicked_tile.occupant.is_in_group(Player.current.name):
				_unselect_tile()
				clear_movement()
				_select_tile(clicked_tile)
			# occupant piece belongs to different player
			elif not clicked_tile.occupant.is_in_group(Player.current.name):
				if clicked_tile.stats.is_threatened:
					capture_piece(clicked_tile.occupant)
					move_piece_to_tile(Piece.selected,clicked_tile)
					_next_turn()
		elif clicked_tile.occupant == null:
			if clicked_tile.stats.is_movement:
				if Piece.selected.is_in_group("Pawn") and not Piece.selected.is_in_group("has_moved") and abs(clicked_tile.board_position - Tile.selected.board_position) == Vector2i(2,0):
					_set_en_passant(clicked_tile)
				move_piece_to_tile(Piece.selected,clicked_tile)
				_next_turn()
			elif clicked_tile.stats.is_special:
				move_piece_to_tile(Piece.selected,clicked_tile)
				perform_castling_move(clicked_tile) # castling
				_next_turn()
			elif clicked_tile.stats.is_threatened:
				if Tile.en_passant and clicked_tile == Tile.en_passant:
					if Piece.en_passant and not Piece.en_passant.is_in_group(Player.current.name):
						capture_piece(Piece.en_passant)
						move_piece_to_tile(Piece.selected,clicked_tile)
						_next_turn()
			
	elif Piece.selected == null: # no piece selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			if clicked_tile.occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				_select_tile(clicked_tile)

#endregion


func _set_en_passant(clicked_tile: Tile):
	Piece.en_passant = Piece.selected
	var en_passant_tile_x = Tile.selected.file + (clicked_tile.file - Tile.selected.file)/2
	var en_passant_tile_y = Tile.selected.rank
	Tile.en_passant = board_array[get_index_from_tile_position(en_passant_tile_x,en_passant_tile_y)]
	Player.en_passant = Player.current


func _clear_en_passant():
	Piece.en_passant = null
	Tile.en_passant = null


func _select_tile(tile: Node3D):
	Tile.selected = tile
	Piece.selected = tile.occupant
	Tile.selected._select()
	show_valid_piece_movement()
	if Piece.selected.is_in_group("King") and not Piece.selected.is_in_group("has_moved"):
		show_valid_castling_movement()


func _unselect_tile():
	Tile.selected._unselect()
	Tile.selected = null
	Piece.selected = null
	clear_movement()


func show_valid_castling_movement():
	var king_tile = Tile.selected
	
	var corner_tiles = [
		board_array[get_index_from_tile_position(Tile.selected.file,0)],
		board_array[get_index_from_tile_position(Tile.selected.file,num_board_columns-1)]
	]
	
	# Check if corner tiles are occupied by unmoved rooks
	var proceed: bool = true

	for tile in corner_tiles:
		if tile.occupant and tile.occupant.is_in_group("Rook") and not tile.occupant.is_in_group("has_moved"):
			# Check if tiles between king and rook are not occupied
			var step = 1 if tile.board_position > king_tile.board_position else -1
			proceed = true
			for tile_column_position in range(king_tile.rank, tile.rank, step):
				if board_array[get_index_from_tile_position(king_tile.file,tile_column_position)] == king_tile:
					if king_tile.stats.is_checked:
						proceed = false
						break
					else:
						continue
				elif board_array[get_index_from_tile_position(king_tile.file,tile_column_position)].occupant:
					proceed = false
					break
				elif abs(tile_column_position - king_tile.rank) <= 2 and not _is_move_legal([king_tile,board_array[get_index_from_tile_position(king_tile.file,tile_column_position)]]):
					proceed = false
					break
				
			var castling_tile = null
			
			if proceed and tile.board_position > king_tile.board_position:
				castling_tile = board_array[get_index_from_tile_position(Tile.selected.file,king_tile.rank + 2)]
			elif proceed and tile.board_position < king_tile.board_position:
				castling_tile = board_array[get_index_from_tile_position(Tile.selected.file,king_tile.rank - 2)]
			
			if castling_tile:
				castling_tile._show_castling()
				tile.occupant._show_castling()


func perform_castling_move(castling_tile: Tile):
	if castling_tile.rank > (num_board_columns/2) - 1:
		var castling_rook = piece_location[get_index_from_tile_position(castling_tile.file,num_board_columns-1)]
		board_array[get_index_from_tile_position(castling_tile.file,num_board_columns-1)].occupant = null
		var castling_rook_destination = board_array[get_index_from_tile_position(castling_tile.file,castling_tile.rank-1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)
	elif castling_tile.rank < (num_board_columns/2) - 1:
		var castling_rook = piece_location[get_index_from_tile_position(castling_tile.file,0)]
		board_array[get_index_from_tile_position(castling_tile.file,0)].occupant = null
		var castling_rook_destination = board_array[get_index_from_tile_position(castling_tile.file,castling_tile.rank+1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)


func detect_check():
	var player_king = _get_king_of(Player.current)
	var player_king_tile = _get_tile_from_piece(player_king)
	
	var opponent_moves = _generate_all_moves(_get_opponent_of(Player.current))
	
	for move in opponent_moves:
		if move[1].occupant and move[1].occupant.is_in_group("King") and move[1].occupant.is_in_group(Player.current.name):
			player_king_tile._set_check()
			break


func clear_check():
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.stats.is_checked:
			tile._unset_check()


func show_valid_piece_movement():
	var moveset:Movement = Piece.selected.stats.movement
	moveset.set_purpose_type(Movement.Purpose.STANDARD_MOVEMENT)
	
	if moveset.distance == 0 and moveset.is_branching:
		resolve_branching_movement(Piece.selected, moveset, Tile.selected)


func resolve_branching_movement(active_piece:Piece, moveset: Movement, origin_tile: Tile):
	var movements = []
	
	for branch in moveset.branches:
		var current_tile_ptr: Tile = origin_tile
		
		branch.purpose = moveset.purpose
		var distance = branch.distance
		
		while distance > 0:
			if current_tile_ptr == null:
				break
			
			if (current_tile_ptr.file + neighboring_tiles[branch.direction].x > num_board_rows-1 
					or current_tile_ptr.file + neighboring_tiles[branch.direction].x < 0
					or current_tile_ptr.rank + neighboring_tiles[branch.direction].y > num_board_columns-1
					or current_tile_ptr.rank + neighboring_tiles[branch.direction].y < 0):
				break
			else:
				current_tile_ptr = board_array[get_index_from_tile_position(current_tile_ptr.file + neighboring_tiles[branch.direction].x,current_tile_ptr.rank + neighboring_tiles[branch.direction].y)]
			
			
			if current_tile_ptr: # current_tile_ptr exists
				if current_tile_ptr.occupant: # current_tile_ptr is occupied
					if active_piece.stats.player != current_tile_ptr.occupant.stats.player: # current_tile_ptr is occupied by opponent piece
						if branch.is_threaten:
							#region Tile can be Threatened
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
								current_tile_ptr._threaten()
								break
							elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
								movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
								break				
							#endregion
					if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
						if not branch.is_jump:
							#region Tile is Blocked
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT: break 
							elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES: break
							#endregion
				elif current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					if current_tile_ptr == Tile.en_passant:
						#region En Passant
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							if active_piece.stats.player != Piece.en_passant.stats.player:
								if branch.is_threaten:
									Tile.en_passant._threaten()
									Piece.en_passant._threaten()
						elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
							movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
						#endregion
					elif branch.is_move:
						#region Tile is empty
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							var legal:bool = false
							for move in legal_moves:
								if move == [_get_tile_from_piece(active_piece), current_tile_ptr]:
									legal = true
							if legal:
								current_tile_ptr.stats.is_movement = true
							else:
								current_tile_ptr.stats.is_checked_movement = true
							
						elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
							movements.append([_get_tile_from_piece(active_piece),current_tile_ptr])
						#endregion
				distance -= 1
			
		if distance == 0 and branch.is_branching:
			if moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
				movements.append_array(resolve_branching_movement(active_piece, branch, current_tile_ptr))
			elif moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
				resolve_branching_movement(active_piece, branch, current_tile_ptr)
	
	if moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
		return movements


func capture_piece(piece):
	piece.translate(Vector3(0,-5,0))
	piece.reparent(%Captured)
	piece._captured()
	piece_capture_audio.play()


func move_piece_to_tile(piece: Piece, tile: Tile):
	clear_check()
	
	#if piece.is_in_group("Pawn"):
		#if piece.is_in_group("Player_One") and tile.board_postion.y == BOARD_LENGTH-1:
			#piece.promote()
			#piece.remove_from_group("Pawn")
			#
		#if piece.is_in_group("Player_Two") and tile.board_postion.y == 0:
			#piece.remove_from_group("Pawn")
	
	Tile.selected._unselect()
	clear_movement()
	Tile.selected.occupant = null
	
	tile.occupant = piece
	piece.global_position = (tile.global_position + piece.global_position * Vector3(0,1,0))
	piece.global_rotation = tile.global_rotation + piece.global_rotation
	piece.reparent(tile)
	piece_move_audio.play()
	
	if not piece.stats.has_moved:
		piece.moved()
	if Piece.selected == piece:
		Piece.selected = null


func clear_movement():
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.stats.is_selected = false
		tile.stats.is_movement = false
		tile.stats.is_checked_movement = false
		tile._unthreaten()
		tile._hide_castling()


## Sets up the next turn
func _next_turn() -> void:
	
	for tile in get_tree().get_nodes_in_group("Tile"):
		piece_location[get_index_from_tile_position(tile.file,tile.rank)] = tile.occupant
	
	# increments the turn number
	turn_num += 1
	Player.previous = Player.current
	Player.current = _get_opponent_of(Player.previous)
	
	if Player.current == Player.en_passant:
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








#func change_piece_resources(old_piece: Node3D, new_piece: Piece_Type):
	#old_piece.find_child("Piece_Mesh").mesh = PIECE_MESH[new_piece]
	#old_piece.set_script(PIECE_SCRIPT[new_piece])
#
#func promote(piece:Piece, promotion: PawnPromotion):
	#var piece_player = piece.player
	#
	#match promotion:
		#PawnPromotion.ROOK:
			#change_piece_resources(piece,Piece_Type.ROOK)
			#piece.add_to_group("Rook")
		#PawnPromotion.BISHOP: 
			#change_piece_resources(piece,Piece_Type.BISHOP)
			#piece.add_to_group("Bishop")
		#PawnPromotion.KNIGHT:
			#change_piece_resources(piece,Piece_Type.KNIGHT)
			#piece.add_to_group("Knight")
		#PawnPromotion.QUEEN:
			#change_piece_resources(piece,Piece_Type.QUEEN)
			#piece.add_to_group("Queen")
	#
	#piece.player = piece_player
	#piece.ready.emit()

class_name BoardObject
extends GameNode3D

signal next_turn(player: int)
signal promotion_requested(piece)
signal game_state_changed(game_state: int)

const TURN_TRANSITION_DELAY_MSEC:int = 500
const MAX_TURN_TRANSITION_LENGTH_MSEC:float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = USER_SETTING.CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC

var current_game_state = GameState.BoardCustomization

var time_turn_ended:int = 0
var time_elapsed_since_turn_ended = 0
var turn_num: int = 0

@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move

const TILE_SCENE:PackedScene = preload("res://scenes/tile.tscn")
const PIECE_SCENE:PackedScene = preload("res://scenes/piece/piece.tscn")

var data: BoardData

func decode_FEN(FE_notation:FEN):
	var fen_decoder = FENDecoder.new(FE_notation)
	data.FEN_board_state = FE_notation
	get_tree().call_group("Tile","clear_states")
	
	fen_decoder.apply(self)
	generate_legal_moves()
	
	clear_check()
	detect_check()


func detect_check():
	var player_king: PieceObject = Player.current.pieces["King"][0]
	var player_king_tile: TileObject = data.tile_array[player_king.data.index]
	
	var opponent_moves: Array[Move] = generate_all_moves(get_opponent_of(Player.current))
	
	for move in opponent_moves:
		if move.destination_tile.occupant and move.destination_tile.occupant.is_in_group("King") and move.destination_tile.occupant.is_in_group(Player.current.name):
			player_king_tile._set_check()
			break


func make_virtual_move(move:Move):
	move.destination_tile.occupant = move.starting_tile.occupant
	move.starting_tile.occupant = null


func unmake_virtual_move(move:Move):
	move.starting_tile.occupant = move.destination_tile.occupant
	move.destination_tile.occupant = data.piece_location[move.destination_tile.data.index]

func is_legal(move:Move):
	var is_legal:bool = true
	make_virtual_move(move)
	
	var opponent_moves: Array[Move] = generate_all_moves(get_opponent_of(Player.current))
	for opposing_move in opponent_moves:
		if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
			is_legal = false
			break
	
	unmake_virtual_move(move)
	
	if is_legal:
		return true


func clear_check():
	for tile in data.tile_array:
		if tile.data.is_checked:
			tile._unset_check()


func get_opponent_of(player: Player):
	if player == data.player_one:
		return data.player_two
	elif player == data.player_two:
		return data.player_one


func set_en_passant(clicked_tile: TileObject):
	PieceObject.en_passant = PieceObject.selected
	var en_passant_tile_rank = TileObject.selected.rank + (clicked_tile.rank - TileObject.selected.rank)/2
	var en_passant_tile_file = TileObject.selected.file
	TileObject.en_passant = data.tile_array[data.get_index(en_passant_tile_rank,en_passant_tile_file)]
	Player.en_passant = Player.current


func clear_en_passant():
	PieceObject.en_passant = null
	TileObject.en_passant = null


func generate_all_moves(player: Player):
	var moves: Array[Move] = []
	for piece in player.all_pieces:
		moves.append_array(generate_moves_from_piece(piece))
	return moves


func generate_legal_moves():
	var pseudo_legal_moves: Array[Move] = generate_all_moves(Player.current)

	for move in pseudo_legal_moves:
		var is_legal:bool = true
		make_virtual_move(move)
		
		var opponent_moves:Array[Move] = generate_all_moves(get_opponent_of(Player.current))
		for opposing_move in opponent_moves:
			if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
				is_legal = false
				break
		
		if is_legal:
			data.legal_moves.append(move)
		
		unmake_virtual_move(move)


func generate_moves_from_piece(piece:PieceObject):
	var moveset:Movement = piece.data.movement
	moveset.set_purpose_type(Movement.Purpose.GENERATE_ALL_MOVES)
	
	if moveset.distance == 0 and moveset.is_branching:
		var moves: Array[Move] = resolve_branching_movement(piece, moveset, data.tile_array[piece.data.index])
		return moves


func _on_gamemode_selection_fen_notation_verified(FEN_notation: FEN) -> void:
	data.FEN_board_state = FEN_notation

func _on_gamemode_selection_column_number_changed(value: int) -> void:
	data.file_count = value


func _on_gamemode_selection_row_number_changed(value: int) -> void:
	data.rank_count = value


func _on_tile_modifier_screen_continue_button_pressed() -> void:
	current_game_state = GameState.Gameplay
	game_state_changed.emit(current_game_state)
	get_tree().call_group("Tile","clear_states")


func _on_game_overlay_new_placement_selected(placement: FEN) -> void:
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.occupant:
			tile.occupant.queue_free()
	data.piece_location.clear()
	data.piece_location.resize(data.rank_count * data.file_count)
	decode_FEN(placement)


func _on_gamemode_selection_continue_button_pressed() -> void:
	generate_board()
	decode_FEN(data.FEN_board_state)
	current_game_state = GameState.BoardCustomization
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))



func generate_board():
	data.tile_array.resize(data.file_count * data.rank_count)
	data.piece_location.resize(data.file_count * data.rank_count)
	
	$BoardBase.mesh.size = Vector3(data.file_count+1 ,0.2, data.rank_count+1)
	
	for tile_num in range(data.rank_count * data.file_count):
		var new_tile = TILE_SCENE.instantiate()
		data.tile_array[tile_num] = new_tile
		new_tile.data = TileDataChess.new()
		new_tile.data.index = tile_num
		new_tile.data.board_position = data.get_board_position(tile_num)
		new_tile.translate(Vector3(
				new_tile.data.file-(float(data.file_count)/2)+0.5, 
				0.1, 
				(float(data.rank_count)/2)-new_tile.data.rank-0.5
			))
		$BoardBase.add_child(new_tile, true)	
		


func _ready() -> void:
	data = BoardData.new(
			load("res://resources/players/player_one.tres"),
			load("res://resources/players/player_two.tres")
			)
			
	Player.current = data.player_one
	Player.previous = data.player_one

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

#region Tile Clicked

func _on_tile_clicked(clicked_tile: TileObject):
	if current_game_state == GameState.BoardCustomization:
		_customization_tile_select(clicked_tile)
	elif current_game_state == GameState.Gameplay:	
		_gameplay_tile_select(clicked_tile)

func _customization_tile_select(clicked_tile: TileObject):
	if clicked_tile.data.is_selected == true:
		clicked_tile._unselect()
	elif clicked_tile.data.is_selected == false:
		clicked_tile._select()

func _gameplay_tile_select(clicked_tile: TileObject):
	if PieceObject.selected and TileObject.selected: # piece is already selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			# Clicked tile and selected tile are the same
			if PieceObject.selected == clicked_tile.occupant and TileObject.selected == clicked_tile:
				_unselect_tile()
			# occupant piece belongs to current player
			elif clicked_tile.occupant.is_in_group(Player.current.name):
				_unselect_tile()
				get_tree().call_group("Tile","clear_states")
				_select_tile(clicked_tile)
			# occupant piece belongs to different player
			elif not clicked_tile.occupant.is_in_group(Player.current.name):
				if clicked_tile.data.is_threatened:
					capture_piece(clicked_tile.occupant)
					move_piece_to_tile(PieceObject.selected,clicked_tile)
					_next_turn()
		elif clicked_tile.occupant == null:
			if clicked_tile.data.is_movement:
				if PieceObject.selected.is_in_group("Pawn") and not PieceObject.selected.data.has_moved and abs(clicked_tile.data.rank - TileObject.selected.data.rank) == 2:
					set_en_passant(clicked_tile)
				move_piece_to_tile(PieceObject.selected,clicked_tile)
				_next_turn()
			elif clicked_tile.data.is_special:
				move_piece_to_tile(PieceObject.selected,clicked_tile)
				perform_castling_move(clicked_tile) # castling
				_next_turn()
			elif clicked_tile.data.is_threatened:
				if TileObject.en_passant and clicked_tile == TileObject.en_passant:
					if PieceObject.en_passant and not PieceObject.en_passant.is_in_group(Player.current.name):
						capture_piece(PieceObject.en_passant)
						move_piece_to_tile(PieceObject.selected,clicked_tile)
						_next_turn()
			
	elif PieceObject.selected == null: # no piece selected
		if clicked_tile.occupant: # Clicked Tile is occupied
			if clicked_tile.occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				_select_tile(clicked_tile)

#endregion


func _select_tile(tile: TileObject):
	TileObject.selected = tile
	PieceObject.selected = tile.occupant
	TileObject.selected._select()
	show_valid_piece_movement()
	if PieceObject.selected.is_in_group("King") and not PieceObject.selected.data.has_moved:
		show_valid_castling_movement()


func _unselect_tile():
	TileObject.selected._unselect()
	TileObject.selected = null
	PieceObject.selected = null
	get_tree().call_group("Tile","clear_states")


func show_valid_castling_movement():
	var king_tile: TileObject = TileObject.selected
	
	var corner_tiles:Array[TileObject] = [
		data.tile_array[data.get_index(king_tile.data.rank,0)],
		data.tile_array[data.get_index(king_tile.data.rank,data.file_count-1)]
	]
	
	# Check if corner tiles are occupied by unmoved rooks
	var proceed: bool = true

	for tile in corner_tiles:
		if tile.occupant and tile.occupant.is_in_group("Rook") and not tile.occupant.data.has_moved:
			# Check if tiles between king and rook are not occupied
			var step:int = 1 if tile.data.file > king_tile.data.file else -1
			proceed = true
			for tile_column_position in range(king_tile.data.file, tile.data.file, step):
				if data.tile_array[data.get_index(king_tile.data.rank,tile_column_position)] == king_tile:
					if king_tile.data.is_checked:
						proceed = false
						break
					else:
						continue
				elif data.tile_array[data.get_index(king_tile.data.rank,tile_column_position)].occupant:
					proceed = false
					break
				elif abs(tile_column_position - king_tile.data.file) <= 2 and not is_legal(Move.new(king_tile,data.tile_array[data.get_index(king_tile.data.rank,tile_column_position)])):
					proceed = false
					break
				
			var castling_tile:TileObject = null
			
			if proceed and tile.data.file > king_tile.data.file:
				castling_tile = data.tile_array[data.get_index(TileObject.selected.data.rank,king_tile.data.file + 2)]
			elif proceed and tile.data.file < king_tile.data.file:
				castling_tile = data.tile_array[data.get_index(TileObject.selected.data.rank,king_tile.data.file - 2)]
			
			if castling_tile:
				data.legal_moves.append(Move.new(king_tile,castling_tile))
				castling_tile._show_castling()


func perform_castling_move(castling_tile: TileObject):
	if castling_tile.data.file > (data.file_count/2) - 1:
		var castling_rook = data.piece_location[data.get_index(castling_tile.rank,data.file_count-1)]
		data.tile_array[data.get_index(castling_tile.rank,data.file_count-1)].occupant = null
		var castling_rook_destination = data.tile_array[data.get_index(castling_tile.data.rank,castling_tile.data.file-1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)
	elif castling_tile.data.file < (data.file_count/2) - 1:
		var castling_rook = data.piece_location[data.get_index(castling_tile.data.rank,0)]
		data.tile_array[data.get_index(castling_tile.rank,0)].occupant = null
		var castling_rook_destination = data.tile_array[data.get_index(castling_tile.data.rank,castling_tile.data.file+1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)


func show_valid_piece_movement():
	var moveset:Movement = PieceObject.selected.data.movement
	moveset.set_purpose_type(Movement.Purpose.STANDARD_MOVEMENT)
	resolve_branching_movement(PieceObject.selected, moveset, TileObject.selected)


func resolve_branching_movement(active_piece:PieceObject, moveset: Movement, origin_tile: TileObject):
	var movements: Array[Move] = []
	
	for branch in moveset.branches:
		var current_tile_ptr: TileObject = origin_tile
		
		branch.purpose = moveset.purpose
		var distance: int = branch.distance
		
		while distance > 0:
			if current_tile_ptr == null:
				break
				
			var next_tile_position: Vector2i = current_tile_ptr.data.board_position + Movement.neighboring_tiles[branch.direction]
				
			if (next_tile_position.x > data.rank_count-1 
					or next_tile_position.x < 0
					or next_tile_position.y > data.file_count-1
					or next_tile_position.y < 0):
				break
			else:
				current_tile_ptr = data.tile_array[data.get_index(next_tile_position.x,next_tile_position.y)]
			
			if current_tile_ptr: # current_tile_ptr exists
				if current_tile_ptr.occupant: # current_tile_ptr is occupied
					if active_piece.data.player != current_tile_ptr.occupant.data.player: # current_tile_ptr is occupied by opponent piece
						if branch.is_threaten:
							#region Tile can be Threatened
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
								current_tile_ptr._threaten()
								break
							elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
								movements.append(Move.new(data.tile_array[active_piece.data.index],current_tile_ptr))		
							#endregion
					if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
						if not branch.is_jump:
							#region Tile is Blocked
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT: 
								break 
							elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
								break	
							#endregion
				elif current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					if current_tile_ptr == TileObject.en_passant:
						#region En Passant
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							if active_piece.data.player != PieceObject.en_passant.data.player:
								if branch.is_threaten:
									TileObject.en_passant._threaten()
									PieceObject.en_passant.data.is_threatened = true
						elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
								movements.append(Move.new(data.tile_array[active_piece.index],current_tile_ptr))		
						#endregion
					elif branch.is_move:
						#region Tile is empty
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							var legal:bool = false
							for move in data.legal_moves:
								if move.array_notation == [data.tile_array[active_piece.data.index], current_tile_ptr]:
									legal = true
							if legal:
								current_tile_ptr.data.is_movement = true
							else:
								current_tile_ptr.data.is_checked_movement = true
						elif moveset.purpose == Movement.Purpose.GENERATE_ALL_MOVES:
								movements.append(Move.new(data.tile_array[active_piece.data.index],current_tile_ptr))		
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


func move_piece_to_tile(piece: PieceObject, tile: TileObject):
	clear_check()
	
	#if piece.is_in_group("Pawn"):
		#if piece.is_in_group("Player_One") and tile.board_postion.y == BOARD_LENGTH-1:
			#piece.promote()
			#piece.remove_from_group("Pawn")
			#
		#if piece.is_in_group("Player_Two") and tile.board_postion.y == 0:
			#piece.remove_from_group("Pawn")
	
	TileObject.selected._unselect()
	get_tree().call_group("Tile","clear_states")
	TileObject.selected.occupant = null
	
	tile.occupant = piece
	piece.global_position = (piece.position * Vector3(0,1,0)) + tile.global_position 
	piece.global_rotation = tile.global_rotation + piece.global_rotation
	piece.reparent(tile)
	piece_move_audio.play()
	
	if not piece.data.has_moved:
		piece.data.has_moved = true
	if PieceObject.selected == piece:
		PieceObject.selected = null

## Sets up the next turn
func _next_turn() -> void:
	
	for tile in data.tile_array:
		data.piece_location[tile.index] = tile.occupant
	
	# increments the turn number
	turn_num += 1
	Player.previous = Player.current
	Player.current = data.get_opponent_of(Player.previous)
	
	if Player.current == Player.en_passant:
		data.clear_en_passant()
	
	data.legal_moves = data.generate_legal_moves()
	if data.legal_moves.is_empty():
		pass # Checkmate
	else:
		data.detect_check()

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

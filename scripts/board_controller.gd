class_name BoardController
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


func _on_gamemode_selection_fen_notation_verified(FEN_notation: FEN) -> void:
	Board.FEN_board_state = FEN_notation

func _on_gamemode_selection_column_number_changed(value: int) -> void:
	Board.file_count = value


func _on_gamemode_selection_row_number_changed(value: int) -> void:
	Board.rank_count = value


func _on_tile_modifier_screen_continue_button_pressed() -> void:
	current_game_state = GameState.Gameplay
	game_state_changed.emit(current_game_state)
	get_tree().call_group("Tile","clear_states")


func _on_game_overlay_new_placement_selected(placement: FEN) -> void:
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.occupant:
			tile.occupant.queue_free()
	Board.piece_location.clear()
	Board.piece_location.resize(Board.rank_count * Board.file_count)
	Board.decode_FEN(placement)


func _on_gamemode_selection_continue_button_pressed() -> void:
	generate_board()
	Board.decode_FEN(Board.FEN_board_state)
	current_game_state = GameState.BoardCustomization
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))



func generate_board():
	Board.generate_virtual_board()
	$BoardBase.mesh.size = Vector3(Board.file_count+1 ,0.2, Board.rank_count+1)
	for tile in Board.tile_array:
		$BoardBase.add_child(tile.controller,true)	

func _ready() -> void:
	Player.current = Board.player_one
	Player.previous = Board.player_one

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
				get_tree().call_group("Tile","clear_states")
				_select_tile(clicked_tile)
			# occupant piece belongs to different player
			elif not clicked_tile.occupant.is_in_group(Player.current.name):
				if clicked_tile.stats.is_threatened:
					capture_piece(clicked_tile.occupant)
					move_piece_to_tile(Piece.selected,clicked_tile)
					_next_turn()
		elif clicked_tile.occupant == null:
			if clicked_tile.stats.is_movement:
				if Piece.selected.is_in_group("Pawn") and not Piece.selected.stats.has_moved and abs(clicked_tile.stats.rank - Tile.selected.stats.rank) == 2:
					Board.set_en_passant(clicked_tile)
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


func _select_tile(tile: Tile):
	Tile.selected = tile
	Piece.selected = tile.occupant
	Tile.selected._select()
	show_valid_piece_movement()
	if Piece.selected.is_in_group("King") and not Piece.selected.stats.has_moved:
		show_valid_castling_movement()


func _unselect_tile():
	Tile.selected._unselect()
	Tile.selected = null
	Piece.selected = null
	get_tree().call_group("Tile","clear_states")


func show_valid_castling_movement():
	var king_tile: Tile = Tile.selected
	
	var corner_tiles:Array[Tile] = [
		Board.tile_array[Tile.get_index(king_tile.stats.rank,0)],
		Board.tile_array[Tile.get_index(king_tile.stats.rank,Board.file_count-1)]
	]
	
	# Check if corner tiles are occupied by unmoved rooks
	var proceed: bool = true

	for tile in corner_tiles:
		if tile.occupant and tile.occupant.is_in_group("Rook") and not tile.occupant.has_moved:
			# Check if tiles between king and rook are not occupied
			var step:int = 1 if tile.file > king_tile.file else -1
			proceed = true
			for tile_column_position in range(king_tile.file, tile.file, step):
				if Board.tile_array[Tile.get_index(king_tile.rank,tile_column_position)] == king_tile:
					if king_tile.stats.is_checked:
						proceed = false
						break
					else:
						continue
				elif Board.tile_array[Tile.get_index(king_tile.stats.rank,tile_column_position)].occupant:
					proceed = false
					break
				elif abs(tile_column_position - king_tile.file) <= 2 and not Move.new(king_tile,Board.tile_array[Tile.get_index(king_tile.rank,tile_column_position)]).is_legal():
					proceed = false
					break
				
			var castling_tile:Tile = null
			
			if proceed and tile.stats.file > king_tile.stats.file:
				castling_tile = Board.tile_array[Tile.get_index(Tile.selected.stats.rank,king_tile.stats.file + 2)]
			elif proceed and tile.stats.file < king_tile.stats.file:
				castling_tile = Board.tile_array[Tile.get_index(Tile.selected.stats.rank,king_tile.stats.file - 2)]
			
			if castling_tile:
				Board.legal_moves.append(Move.new(king_tile,castling_tile))
				castling_tile._show_castling()


func perform_castling_move(castling_tile: Tile):
	if castling_tile.file > (Board.file_count/2) - 1:
		var castling_rook = Board.piece_location[Tile.get_index(castling_tile.rank,Board.file_count-1)]
		Board.tile_array[Tile.get_index(castling_tile.rank,Board.file_count-1)].occupant = null
		var castling_rook_destination = Board.tile_array[Tile.get_index(castling_tile.stats.rank,castling_tile.stats.file-1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)
	elif castling_tile.file < (Board.file_count/2) - 1:
		var castling_rook = Board.piece_location[Tile.get_index(castling_tile.rank,0)]
		Board.tile_array[Tile.get_index(castling_tile.rank,0)].occupant = null
		var castling_rook_destination = Board.tile_array[Tile.get_index(castling_tile.rank,castling_tile.file+1)]
		move_piece_to_tile(castling_rook, castling_rook_destination)


func show_valid_piece_movement():
	var moveset:Movement = Piece.selected.stats.movement
	moveset.set_purpose_type(Movement.Purpose.STANDARD_MOVEMENT)
	resolve_branching_movement(Piece.selected, moveset, Tile.selected)


func resolve_branching_movement(active_piece:Piece, moveset: Movement, origin_tile: Tile):
	var movements: Array[Move] = []
	
	for branch in moveset.branches:
		var current_tile_ptr: Tile = origin_tile
		
		branch.purpose = moveset.purpose
		var distance: int = branch.distance
		
		while distance > 0:
			if current_tile_ptr == null:
				break
				
			var next_tile_position: Vector2i = current_tile_ptr.stats.board_position + Movement.neighboring_tiles[branch.direction]
				
			if (next_tile_position.x > Board.rank_count-1 
					or next_tile_position.x < 0
					or next_tile_position.y > Board.file_count-1
					or next_tile_position.y < 0):
				break
			else:
				current_tile_ptr = Board.tile_array[Tile.get_index(next_tile_position.x,next_tile_position.y)]
			
			if current_tile_ptr: # current_tile_ptr exists
				if current_tile_ptr.occupant: # current_tile_ptr is occupied
					if active_piece.stats.player != current_tile_ptr.occupant.stats.player: # current_tile_ptr is occupied by opponent piece
						if branch.is_threaten:
							#region Tile can be Threatened
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
								current_tile_ptr._threaten()
								break		
							#endregion
					if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
						if not branch.is_jump:
							#region Tile is Blocked
							if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT: 
								break 
							#endregion
				elif current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					if current_tile_ptr == Tile.en_passant:
						#region En Passant
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							if active_piece.stats.player != Piece.en_passant.stats.player:
								if branch.is_threaten:
									Tile.en_passant._threaten()
									Piece.en_passant.stats.is_threatened = true
						#endregion
					elif branch.is_move:
						#region Tile is empty
						if moveset.purpose == Movement.Purpose.STANDARD_MOVEMENT:
							var legal:bool = false
							for move in Board.legal_moves:
								if move.array_notation == [Board.tile_array[active_piece.stats.index], current_tile_ptr]:
									legal = true
							if legal:
								current_tile_ptr.stats.is_movement = true
							else:
								current_tile_ptr.stats.is_checked_movement = true
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
	Board.clear_check()
	
	#if piece.is_in_group("Pawn"):
		#if piece.is_in_group("Player_One") and tile.board_postion.y == BOARD_LENGTH-1:
			#piece.promote()
			#piece.remove_from_group("Pawn")
			#
		#if piece.is_in_group("Player_Two") and tile.board_postion.y == 0:
			#piece.remove_from_group("Pawn")
	
	Tile.selected._unselect()
	get_tree().call_group("Tile","clear_states")
	Tile.selected.occupant = null
	
	tile.occupant = piece
	piece.global_position = (piece.position * Vector3(0,1,0)) + tile.global_position 
	piece.global_rotation = tile.global_rotation + piece.global_rotation
	piece.reparent(tile)
	piece_move_audio.play()
	
	if not piece.stats.has_moved:
		piece.stats.has_moved = true
	if Piece.selected == piece:
		Piece.selected = null

## Sets up the next turn
func _next_turn() -> void:
	
	for tile in Board.tile_array:
		Board.piece_location[tile.index] = tile.occupant
	
	# increments the turn number
	turn_num += 1
	Player.previous = Player.current
	Player.current = Board.get_opponent_of(Player.previous)
	
	if Player.current == Player.en_passant:
		Board.clear_en_passant()
	
	Board.legal_moves = Board.generate_legal_moves()
	if Board.legal_moves.is_empty():
		pass # Checkmate
	else:
		Board.detect_check()

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

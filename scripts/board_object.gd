class_name BoardObject
extends Node3D

signal turn_changed(player: int)
signal promotion_requested(piece)
signal game_state_changed(game_state: int)

enum GameState {
	BoardCustomization,
	Gameplay
}

var _current_game_state = GameState.BoardCustomization

var _time_turn_ended:int = 0
var _time_elapsed_since_turn_ended:int = 0
var _turn_num: int = 0

@onready var _piece_capture_audio = $Piece_capture
@onready var _piece_move_audio = $Piece_move

const TILE_SCENE:PackedScene = preload("res://scenes/tile.tscn")
const PIECE_SCENE:PackedScene = preload("res://scenes/piece/piece.tscn")

var data: BoardData


func _ready() -> void:
	data = BoardData.new(
			load("res://resources/players/player_one.tres"),
			load("res://resources/players/player_two.tres")
			)

	Player.current = data.player_one
	Player.previous = data.player_one


func _process(_delta: float) -> void:
	if Player.previous != Player.current:
		if _time_turn_ended == 0:
			_time_turn_ended = Time.get_ticks_msec()

		_time_elapsed_since_turn_ended = (
				Time.get_ticks_msec()
				- _time_turn_ended
				- data.TURN_TRANSITION_DELAY_MSEC
				)
		if _time_elapsed_since_turn_ended > 0:
			var board_base_color: Color = $BoardBase.material_override.albedo_color

			var lerp_weight: float = (
					_time_elapsed_since_turn_ended
					* data.TURN_TRANSITION_SPEED
					)

			if lerp_weight < 1:
				board_base_color = Player.previous.color.lerp(Player.current.color,lerp_weight)

			elif lerp_weight >= 1:
				Player.previous = Player.current
				_time_turn_ended = 0
				_time_elapsed_since_turn_ended = 0
				board_base_color = Player.current.color


func _on_gamemode_selection_fen_notation_verified(FEN_notation: FEN) -> void:
	data.FEN_board_state = FEN_notation


func _on_gamemode_selection_column_number_changed(value: int) -> void:
	data.file_count = value


func _on_gamemode_selection_row_number_changed(value: int) -> void:
	data.rank_count = value


func _on_tile_modifier_screen_back_button_pressed() -> void:
	for child in $BoardBase.get_children():
		if child.occupant:
			child.occupant.data.player.remove_piece(child.occupant)
		$BoardBase.remove_child(child)
		child.queue_free()

	data.tile_array.clear()
	data.piece_array.clear()

func _on_tile_modifier_screen_continue_button_pressed() -> void:
	_current_game_state = GameState.Gameplay
	game_state_changed.emit(_current_game_state)
	get_tree().call_group("Tile","clear_states")


func _on_game_overlay_new_placement_selected(placement: FEN) -> void:
	data.piece_array.clear()
	for tile in data.tile_array:
		if tile.occupant:
			var piece: PieceObject = tile.occupant
			tile.occupant = null
			tile.remove_child(piece)
			piece.data.player.remove_piece(piece)
			piece.queue_free()

	data.piece_array.resize(data.rank_count * data.file_count)
	load_FEN(placement)


func _on_gamemode_selection_continue_button_pressed() -> void:
	generate_board()
	load_FEN(data.FEN_board_state)
	_current_game_state = GameState.BoardCustomization
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.clicked.connect(Callable(self,"_on_tile_clicked"))

func generate_board() -> void:
	data.tile_array.resize(data.file_count * data.rank_count)
	data.piece_array.resize(data.file_count * data.rank_count)

	# Change the size of the board base to match the size of the board
	$BoardBase.mesh.size = Vector3(data.file_count+1 ,0.2, data.rank_count+1)

	for tile_num in range(data.rank_count * data.file_count):
		var new_tile = TILE_SCENE.instantiate()
		data.tile_array[tile_num] = new_tile
		new_tile.data = TileDataChess.new()
		new_tile.data.index = tile_num
		new_tile.data.board_position = data.get_board_position(tile_num)

		# move tile to its location on the board
		new_tile.translate(Vector3(
				new_tile.data.file-(float(data.file_count)/2)+0.5,
				0.1,
				(float(data.rank_count)/2)-new_tile.data.rank-0.5
			))
		$BoardBase.add_child(new_tile, true)


func load_FEN(FE_notation:FEN) -> void:
	var fen_decoder = FENDecoder.new(FE_notation)
	data.FEN_board_state = FE_notation
	get_tree().call_group("Tile","clear_states")

	fen_decoder.apply(self)

	data.legal_moves = MoveList.new(data)
	data.legal_moves.generate_legal_moves()

	clear_check()
	detect_check()


func detect_check() -> void:
	var player_king: PieceObject = Player.current.pieces["King"][0]
	var player_king_tile: TileObject = data.tile_array[player_king.data.index]

	var opponent_moves: MoveList = MoveList.new(data)
	opponent_moves.generate_pseudo_legal_moves(data.get_opponent_of(Player.current))

	for move in opponent_moves.moves:
		if (	move.destination_tile.occupant
				and move.destination_tile.occupant.is_in_group("King")
				and move.destination_tile.occupant.is_in_group(Player.current.name)
				):
			player_king_tile._set_check()
			break

func clear_check() -> void:
	for tile in data.tile_array:
		if tile.data.is_checked:
			tile._unset_check()


func set_en_passant(clicked_tile: TileObject) -> void:
	PieceObject.en_passant = PieceObject.selected
	var en_passant_tile_rank = (
			TileObject.selected.data.rank
			+ (clicked_tile.data.rank - TileObject.selected.data.rank)/2
			)
	var en_passant_tile_file = TileObject.selected.data.file
	TileObject.en_passant = data.tile_array[data.get_index(en_passant_tile_rank,en_passant_tile_file)]
	Player.en_passant = Player.current


func clear_en_passant() -> void:
	PieceObject.en_passant = null
	TileObject.en_passant = null

#region Tile Clicked

func _on_tile_clicked(clicked_tile: TileObject) -> void:
	if _current_game_state == GameState.BoardCustomization:
		_customization_tile_select(clicked_tile)
	elif _current_game_state == GameState.Gameplay:
		_gameplay_tile_select(clicked_tile)

func _customization_tile_select(clicked_tile: TileObject) -> void:
	if clicked_tile.data.is_selected == true:
		clicked_tile._unselect()
	elif clicked_tile.data.is_selected == false:
		clicked_tile._select()

func _gameplay_tile_select(clicked_tile: TileObject) -> void:
	if PieceObject.selected and TileObject.selected: # object already selected
		if clicked_tile.occupant: # Clicked Tile is occupied

			if (	PieceObject.selected == clicked_tile.occupant
					and TileObject.selected == clicked_tile # Clicked tile and selected tile are the same
					):
				_unselect_tile()

			elif clicked_tile.occupant.is_in_group(Player.current.name): # occupant piece belongs to current player
				_unselect_tile()
				get_tree().call_group("Tile","clear_states")
				_select_tile(clicked_tile)

			elif (	not clicked_tile.occupant.is_in_group(Player.current.name) # occupant piece belongs to different player
					and clicked_tile.data.is_threatened
					):
				capture_piece(clicked_tile.occupant)
				move_piece_to_tile(PieceObject.selected,clicked_tile)
				next_turn()

		elif clicked_tile.occupant == null:
			if clicked_tile.data.is_movement:
				if (	PieceObject.selected.is_in_group("Pawn")
						and not PieceObject.selected.data.has_moved
						and abs(clicked_tile.data.rank - TileObject.selected.data.rank) == 2
						):
					set_en_passant(clicked_tile)
				move_piece_to_tile(PieceObject.selected,clicked_tile)
				next_turn()

			elif clicked_tile.data.is_castling:
				move_piece_to_tile(PieceObject.selected,clicked_tile)
				_perform_castling_move(clicked_tile) # castling
				next_turn()

			elif (	clicked_tile.data.is_threatened
					and TileObject.en_passant == clicked_tile
					and PieceObject.en_passant != null
					and not PieceObject.en_passant.is_in_group(Player.current.name)
					):
						capture_piece(PieceObject.en_passant)
						move_piece_to_tile(PieceObject.selected,clicked_tile)
						next_turn()

	elif (	PieceObject.selected == null # no piece selected
			and clicked_tile.occupant != null # Clicked Tile is occupied
			and clicked_tile.occupant.is_in_group(Player.current.name) # occupant piece belongs to current player
			):
		_select_tile(clicked_tile)

#endregion


func _select_tile(tile: TileObject) -> void:
	TileObject.selected = tile
	PieceObject.selected = tile.occupant
	TileObject.selected._select()
	show_piece_movement()


func _unselect_tile() -> void:
	TileObject.selected._unselect()
	TileObject.selected = null
	PieceObject.selected = null
	get_tree().call_group("Tile","clear_states")



func _perform_castling_move(castling_tile: TileObject) -> void:
	var middle_file_value: float = (data.file_count/2) - 1
	var castling_rook_index: int
	var destination_index: int

	if castling_tile.data.file > middle_file_value:
		castling_rook_index = data.get_index(
				castling_tile.data.rank,
				data.file_count-1
				)

		destination_index = data.get_index(
				castling_tile.data.rank,
				castling_tile.data.file-1
				)

	elif castling_tile.data.file < middle_file_value:
		castling_rook_index = data.get_index(castling_tile.data.rank,0)
		destination_index = data.get_index(
				castling_tile.data.rank,
				castling_tile.data.file+1
				)

	var castling_rook = data.piece_array[castling_rook_index]
	var castling_rook_destination = data.tile_array[destination_index]
	data.tile_array[castling_rook_index].occupant = null
	move_piece_to_tile(castling_rook, castling_rook_destination)


func show_piece_movement() -> void:
	var moveset:Movement = PieceObject.selected.data.movement
	resolve_branching_movement(
			PieceObject.selected,
			moveset,
			TileObject.selected
			)

# SAME LOGIC USED IN MoveList RESOURCE.
# IF THE LOGIC IS CHANGED HERE, MAKE SURE TO CHANGE THAT AS WELL
func resolve_branching_movement(
		active_piece:PieceObject,
		moveset: Movement,
		origin_tile: TileObject
		) -> void:

	for branch in moveset.branches:
		var current_tile_ptr: TileObject = origin_tile

		branch.purpose = moveset.purpose
		var distance: int = branch.distance

		while distance > 0:
			if current_tile_ptr == null: break# current_tile_ptr does not exists

			var next_tile_position: Vector2i = (
					current_tile_ptr.data.board_position
					+ Movement.neighboring_tiles[branch.direction]
					)

			if (	next_tile_position.x > data.rank_count-1
					or next_tile_position.x < 0
					or next_tile_position.y > data.file_count-1
					or next_tile_position.y < 0
					):
				break
			current_tile_ptr = data.tile_array[
					data.get_index(
							next_tile_position.x,
							next_tile_position.y
							)
					]


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
								active_piece.data.castling_kingside_valid = false
							elif branch.direction == Movement.Direction.WEST:
								active_piece.data.castling_queenside_valid = false


			if branch.is_castling:
				var king_tile: TileObject = TileObject.selected

				if (	active_piece.data.has_moved # if king has moved
						or active_piece.data.is_checked # if king is in check
						or (	branch.direction == Movement.Direction.EAST
								and not active_piece.data.castling_kingside_valid)	# if east tile is checked
						or (	branch.direction == Movement.Direction.WEST
								and not active_piece.data.castling_queenside_valid) # if west tile is checked
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
			resolve_branching_movement(active_piece, branch, current_tile_ptr)



func capture_piece(piece) -> void:
	piece.translate(Vector3(0,-5,0))
	piece.reparent(%Captured)
	piece._captured()
	_piece_capture_audio.play()


func move_piece_to_tile(piece: PieceObject, tile: TileObject) -> void:
	clear_check()
	TileObject.selected._unselect()
	get_tree().call_group("Tile","clear_states")
	TileObject.selected.occupant = null


	tile.occupant = piece
	piece.global_position = (piece.position * Vector3(0,1,0)) + tile.global_position
	piece.global_rotation = tile.global_rotation + piece.global_rotation
	piece.reparent(tile)
	piece.data.index = tile.data.index
	_piece_move_audio.play()

	if not piece.data.has_moved:
		piece._moved(true)

	if PieceObject.selected == piece:
		PieceObject.selected = null

## Sets up the next turn
func next_turn() -> void:
	# match occupants in piece_array to their respective tiles in tile_array
	for tile in data.tile_array:
		data.piece_array[tile.data.index] = tile.occupant

	# increments the turn number
	_turn_num += 1
	Player.previous = Player.current
	Player.current = data.get_opponent_of(Player.previous)


	if Player.current == Player.en_passant:
		clear_en_passant()

	data.legal_moves.generate_legal_moves()
	if data.legal_moves.moves.is_empty():
		pass # Checkmate
	else:
		detect_check()

	turn_changed.emit()








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

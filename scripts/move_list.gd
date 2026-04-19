class_name MoveList
extends RefCounted

var board_data: BoardData
var moves: Array[Move] = []

static func generate_moves(board_data: BoardData):
	var move_list = MoveList.new(board_data)

	for piece in Player.current.all_pieces:
		move_list.generate_piece_moves(piece)


func generate_piece_moves(piece: PieceObject):
	pass



func _init(board_data:BoardData) -> void:
	self.board_data = board_data


# create list of all possible moves
func generate_pseudo_legal_moves(player: Player):
	if not moves.is_empty():
		moves.clear()

	for piece in player.all_pieces:
		var moveset:Movement = piece.data.movement.get_duplicate()
		if moveset.distance == 0 and moveset.is_branching:
			get_all_moves(piece, moveset, Match.board.data.tile_array[piece.data.index])


func get_all_moves(active_piece:PieceObject, moveset: Movement, origin_tile: TileObject):

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

			var move: Move = Move.new(
				Match.board.data.tile_array[active_piece.data.index],
				current_tile_ptr)


			if branch.is_threaten:
				# NORMAL THREATEN LOGIC
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece.data.player != current_tile_ptr.occupant.data.player # current_tile_ptr is occupied by opponent piece
						):
					moves.append(move)

				# EN PASSANT LOGIC
				elif ( 	current_tile_ptr.occupant == null	# current_tile_ptr is not occupied
						and PieceObject.en_passant
						and active_piece.data.player != PieceObject.en_passant.data.player
						and current_tile_ptr == TileObject.en_passant
						):
					moves.append(move)

			if not branch.is_jump:
				# JUMP LOGIC
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece != current_tile_ptr.occupant # current_tile_ptr not is occupied by active piece
						):
					break

			if branch.is_move:
				#MOVEMENT LOGIC
				if current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					moves.append(move)

			if branch.is_castling:
				var king_tile: TileObject = Match.board.data.tile_array[Player.current.pieces["King"][0].data.index]

				# Get rook tile for current castling side
				var rook_tile: TileObject
				if current_tile_ptr.data.board_position > king_tile.data.board_position:
					rook_tile = Match.board.data.tile_array[Match.get_board_index(king_tile.data.rank,Match.board.data.file_count-1)]
				elif current_tile_ptr.data.board_position < king_tile.data.board_position:
					rook_tile = Match.board.data.tile_array[Match.get_board_index(king_tile.data.rank,0)]

				if (	not rook_tile.occupant # if no occupant
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
					if Match.board.data.tile_array[Match.get_board_index(king_tile.data.rank,tile_file)].occupant:
						is_empty_between_pieces = false

				if not is_empty_between_pieces: # tiles between rook and king are occupied
					break
				moves.append(move)
				continue


			distance -= 1

		if branch.is_branching and distance == 0:
			get_all_moves(active_piece, branch, current_tile_ptr)


# create list of all legal moves
func generate_legal_moves(player:Player):
	if not moves.is_empty():
		moves.clear()

	var virtual_board: VirtualBoard = VirtualBoard.new(Match.board.data)

	var pseudo_legal: MoveList = MoveList.new(Match.board.data)
	pseudo_legal.generate_pseudo_legal_moves(player)

	for move in pseudo_legal.moves:
		var is_legal_move:bool = true
		virtual_board.make_move(move)

		var opponent = Match.get_opponent_of(player)
		var opposing:MoveList = MoveList.new(Match.board.data)
		opposing.generate_pseudo_legal_moves(opponent)

		for opposing_move in opposing.moves:
			if opposing_move and opposing_move.destination_tile.occupant == player.pieces["King"][0]:
				is_legal_move = false
				break

		if is_legal_move:
			moves.append(move)

		virtual_board.unmake_move(move)


func contains_move(move:Array[TileObject]) -> bool:
	for list_move in moves:
		if [list_move.starting_tile, list_move.destination_tile] == move:
			return true

	return false


func is_legal(move:Move):
	var is_legal_move:bool = true

	var virtual_board: VirtualBoard = VirtualBoard.new(Match.board.data)
	virtual_board.make_move(move)

	var opponent_moves: MoveList = MoveList.new(virtual_board.get_virtual_Match.board.data())
	opponent_moves.generate_pseudo_legal_moves(Match.get_opponent_of(Player.current))

	for opposing_move in opponent_moves.moves:
		if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
			is_legal_move = false
			break

	virtual_board.unmake_move(move)

	if is_legal:
		return true

class_name MoveList

var board_data: BoardData

var moves: Array[Move] = []

func _init(board_data:BoardData) -> void:
	self.board_data = board_data

# create list of all possible moves
func generate_pseudo_legal_moves(player: Player):
	if not moves.is_empty():
		moves.clear()

	for piece in player.all_pieces:
		var moveset:Movement = piece.data.movement

		if moveset.distance == 0 and moveset.is_branching:
			get_all_moves(piece, moveset, board_data.tile_array[piece.data.index])


func get_all_moves(active_piece:PieceObject, moveset: Movement, origin_tile: TileObject):
	for branch in moveset.branches:
		var current_tile_ptr: TileObject = origin_tile
		var distance: int = branch.distance

		branch.purpose = moveset.purpose

		while distance > 0:
			if current_tile_ptr == null:
				break

			var next_tile_position: Vector2i = current_tile_ptr.data.board_position + Movement.neighboring_tiles[branch.direction]

			if (next_tile_position.x > board_data.rank_count-1
					or next_tile_position.x < 0
					or next_tile_position.y > board_data.file_count-1
					or next_tile_position.y < 0):
				break
			else:
				current_tile_ptr = board_data.tile_array[board_data.get_index(next_tile_position.x,next_tile_position.y)]

			if current_tile_ptr.occupant: # current_tile_ptr is occupied
				if active_piece.data.player != current_tile_ptr.occupant.data.player: # current_tile_ptr is occupied by opponent piece
					if branch.is_threaten:
						moves.append(Move.new(
								board_data.tile_array[active_piece.data.index],
								current_tile_ptr)
								)
				if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
					if not branch.is_jump:
						break
			elif current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
				if current_tile_ptr == TileObject.en_passant:
					moves.append(Move.new(
							board_data.tile_array[active_piece.data.index],
							current_tile_ptr)
							)
				elif branch.is_move:
					moves.append(Move.new(
							board_data.tile_array[active_piece.data.index],
							current_tile_ptr)
							)
			distance -= 1

		if distance == 0 and branch.is_branching:
			get_all_moves(active_piece, branch, current_tile_ptr)


# create list of all legal moves
func generate_legal_moves():
	if not moves.is_empty():
		moves.clear()

	var virtual_board: VirtualBoard = VirtualBoard.new(board_data)

	var pseudo_legal: MoveList = MoveList.new(board_data)
	pseudo_legal.generate_pseudo_legal_moves(Player.current)

	for move in pseudo_legal.moves:
		var is_legal:bool = true
		virtual_board.make_move(move)

		var opponent = board_data.get_opponent_of(Player.current)
		var opposing:MoveList = MoveList.new(board_data)
		opposing.generate_pseudo_legal_moves(opponent)

		for opposing_move in opposing.moves:
			if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
				is_legal = false
				break

		if is_legal:
			moves.append(move)

		virtual_board.unmake_move(move)



func is_legal(move:Move):
	var is_legal:bool = true

	var virtual_board: VirtualBoard = VirtualBoard.new(board_data)
	virtual_board.make_move(move)

	var opponent_moves: MoveList = MoveList.new(virtual_board.get_virtual_board_data())
	opponent_moves.generate_pseudo_legal_moves(board_data.get_opponent_of(Player.current))

	for opposing_move in opponent_moves.moves:
		if opposing_move and opposing_move.destination_tile.occupant == Player.current.pieces["King"][0]:
			is_legal = false
			break

	virtual_board.unmake_move(move)

	if is_legal:
		return true

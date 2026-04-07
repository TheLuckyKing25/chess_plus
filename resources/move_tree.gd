class_name MoveTree
extends RefCounted

var root_tile: TileObject # root node

var current_tile: TileObject # node data

var next_tile: Array[MoveTree] # children

static func create_move_tree(starting_tile:TileObject, movement: Movement):
	pass


func get_next_tile(current_tile: TileObject, direction:Movement.Direction):
	var next_tile_position: Vector2i = (
			current_tile.data.board_position
			+ Movement.neighboring_tiles[direction]
			)

	if (	next_tile_position.x > Match.board_data.rank_count-1
			or next_tile_position.x < 0
			or next_tile_position.y > Match.board_data.file_count-1
			or next_tile_position.y < 0
			):
		return # next_tile does not exist

	return Match.board_data.tile_array[
			Match.board_data.get_index(
					next_tile_position.x,
					next_tile_position.y
					)
			]

func get_all_moves(active_piece:PieceObject, moveset: Movement, origin_tile: TileObject):

	for branch in moveset.branches:
		var current_tile_ptr: TileObject = origin_tile

		branch.purpose = moveset.purpose
		var distance: int = branch.distance
		var can_proceed_with_branch: bool = true
		var has_slid:bool = false

		while distance > 0:
			current_tile_ptr = get_next_tile(current_tile_ptr, branch.direction)

			if current_tile_ptr == null:
				break # current_tile_ptr does not exist

			var move: Move = Move.new(
				Match.board_data.tile_array[active_piece.data.index],
				current_tile_ptr)


			if branch.is_threaten:
				# NORMAL THREATEN LOGIC
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece.data.player != current_tile_ptr.occupant.data.player # current_tile_ptr is occupied by opponent piece
						):
					pass #moves.append(move)

				# EN PASSANT LOGIC
				elif ( 	current_tile_ptr.occupant == null	# current_tile_ptr is not occupied
						and PieceObject.en_passant
						and active_piece.data.player != PieceObject.en_passant.data.player
						and current_tile_ptr == TileObject.en_passant
						):
					pass #moves.append(move)

			if not branch.is_jump:
				# JUMP LOGIC
				if (	current_tile_ptr.occupant # current_tile_ptr is occupied
						and active_piece != current_tile_ptr.occupant # current_tile_ptr not is occupied by active piece
						):
					break

			if branch.is_move:
				#MOVEMENT LOGIC
				if current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					pass #moves.append(move)

			if branch.is_castling:
				var king_tile: TileObject = Match.board_data.tile_array[Player.current.pieces["King"][0].data.index]

				# Get rook tile for current castling side
				var rook_tile: TileObject
				if current_tile_ptr.data.board_position > king_tile.data.board_position:
					rook_tile = Match.board_data.tile_array[Match.board_data.get_index(king_tile.data.rank,Match.board_data.file_count-1)]
				elif current_tile_ptr.data.board_position < king_tile.data.board_position:
					rook_tile = Match.board_data.tile_array[Match.board_data.get_index(king_tile.data.rank,0)]

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
					if Match.board_data.tile_array[Match.board_data.get_index(king_tile.data.rank,tile_file)].occupant:
						is_empty_between_pieces = false

				if not is_empty_between_pieces: # tiles between rook and king are occupied
					break
				pass #moves.append(move)
				continue


			distance -= 1

		if branch.is_branching and distance == 0:
			get_all_moves(active_piece, branch, current_tile_ptr)

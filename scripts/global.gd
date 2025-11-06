extends Node

#var checked_king_moveset: Array[Tile] = []
#
#
#var checking_pieces: Array[Piece] = []
#
#
#var checking_tiles: Array[Tile] = []


var king_rook_relation: Array[Dictionary] = []


#func _set_check_states(checking_player: Player) -> void:
	#var opponent_king: King 
	#opponent_king = checking_player.opponent().king
	#
	#for tile in checking_tiles:
		#tile.set_state(Tile.State.CHECKING)
	#for piece in checking_pieces:
		#piece.set_state(Piece.State.CHECKING)
#
	#opponent_king.set_state(Piece.State.CHECKED)
#
#
### Creates two player classes.
#func create_players() -> void:
	#Board.players.append(Player.new(1,Game.Colour.PALETTE[Game.Colour.PLAYER][0]))
	#Board.players.append(Player.new(2,Game.Colour.PALETTE[Game.Colour.PLAYER][1]))
#
#
### Checks if castling is legal between a [King] and a [Rook].
### Returns [code]true[/code] if legal, returns [code]false[/code] if not legal.
#func is_castling_legal(piece1: King, piece2: Rook) -> bool:
	#var piece_check: bool 
	#var tile_check: bool
	#var position1: Vector2i
	#var position2: Vector2i
	#var position_difference: Vector2i 
	#var new_x: int 
	#var lesser_y:int 
	#
	#piece_check = piece1.is_castling_valid() and piece2.is_castling_valid()
	#if not piece_check:
		#return false
		#
	#tile_check = true
	#position1 = piece1.on_tile.board_position
	#position2 = piece2.on_tile.board_position
	#position_difference = abs(position1 - position2)
	#new_x = position1.x
	#lesser_y = position2.y if position1 > position2 else position1.y
	#
	#for y in range(1,position_difference.y):
		#var middle_tile: Tile
		#
		#middle_tile = Tile.find_from_position(Vector2i(new_x,y+lesser_y))
		#if middle_tile.occupant or middle_tile.is_threatened_by(Player.current.opponent()):
			#tile_check = false
			#break
	#
	#return piece_check and tile_check
#
#
#func print_move() -> void:
		#print(
			#"%10s" % Piece.selected.object.name 
			#+ " moves from " 
			#+ Piece.selected.on_tile.object_tile.name 
			#+ " to " 
			#+ Tile.selected.object_tile.name
		#)

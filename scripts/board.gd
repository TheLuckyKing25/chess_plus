extends Game

@export var selected_piece: Node3D

signal new_turn

func _on_ready() -> void:
	get_tree().call_group("Tile","find_neighbors")


## Selects the given piece
func _on_piece_clicked(new_selected_piece: Node3D) -> void:
	if selected_piece:
		
		# unselect piece by clicking on it again
		if new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"flag_is_enabled")):
			new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"unset_flag"))
			get_tree().call_group("Tile","clear_move_states")
			selected_piece = null

		# select tile by clicking an opponent piece
		elif not new_selected_piece.is_in_group(player_groups[current_player]):
			if new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_THREATENED,Callable(self,"flag_is_enabled")):
				new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_CAPTURED,Callable(self,"set_flag"))
				new_selected_piece.get_parent().tile_selected.emit(new_selected_piece.get_parent())

		# unselect the current piece and select the new piece
		elif new_selected_piece.player == selected_piece.player and new_selected_piece != selected_piece: 
			selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"unset_flag"))
			get_tree().call_group("Tile","clear_move_states")
			new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"set_flag"))
			new_selected_piece.piece_selected.emit()
			selected_piece = new_selected_piece
			
	# select the newly selected piece
	elif not selected_piece: 
		if not new_selected_piece.is_in_group(player_groups[current_player]):
			return
		selected_piece = new_selected_piece
		new_selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"set_flag"))
		new_selected_piece.piece_selected.emit()


func _on_tile_selected(tile: Node3D) -> void:
	var proceed = true
	if selected_piece.is_in_group("Pawn") and tile.en_passant_occupant and tile.en_passant_occupant != selected_piece:
		tile.en_passant_occupant.piece_state(PieceStateFlag.PIECE_STATE_CAPTURED,Callable(self,"set_flag"))
	
	if tile.tile_state(TileStateFlag.TILE_STATE_SPECIAL,Callable(self,"flag_is_enabled")):
		var castling_king = selected_piece
		tile.castle.emit()
		proceed = false
		selected_piece = castling_king
		
	selected_piece.piece_state(PieceStateFlag.PIECE_STATE_SELECTED,Callable(self,"unset_flag"))
	get_tree().call_group("Tile","clear_move_states")
	selected_piece.disconnect_from_tile()
	selected_piece.get_parent().occupant = null
	
	tile.occupant = selected_piece
	selected_piece.reparent(tile)
	selected_piece.global_position = (
			tile.global_position 
			* Vector3(1,0,1)
			+ selected_piece.global_position 
			* Vector3(0,1,0)
	)
	selected_piece.connect_to_tile()
	
	if not selected_piece.is_in_group("has_moved"):
		selected_piece.add_to_group("has_moved")
		selected_piece.call("moved")
	
	if selected_piece.is_in_group("Pawn"):
		if selected_piece.is_in_group("Player_One") and not tile.neighboring_tiles[Direction.SOUTH]:
			selected_piece.remove_from_group("Pawn")
			promote(PawnPromotion.PAWN_PROMOTION_QUEEN)
		if selected_piece.is_in_group("Player_Two") and not tile.neighboring_tiles[Direction.NORTH]:
			selected_piece.remove_from_group("Pawn")
			promote(PawnPromotion.PAWN_PROMOTION_QUEEN)
	
	selected_piece = null
	if proceed:
		new_turn.emit()

func change_piece_resources(old_piece: Node3D, new_piece: PieceType):
	old_piece.find_child("Piece_Mesh").mesh = piece_mesh[new_piece]
	old_piece.find_child("Outline").mesh = piece_mesh[new_piece]
	old_piece.set_script(piece_script[new_piece])
	

func promote(promotion: PawnPromotion):
	var player_piece_abreviation = ["P1", "P2"]
	var piece_groups = selected_piece.get_groups()
	var piece_player = selected_piece.player
	
	match promotion:
		PawnPromotion.PAWN_PROMOTION_ROOK:
			change_piece_resources(selected_piece,PieceType.PIECE_TYPE_ROOK)
			selected_piece.add_to_group("Rook")
		PawnPromotion.PAWN_PROMOTION_BISHOP: 
			change_piece_resources(selected_piece,PieceType.PIECE_TYPE_BISHOP)
			selected_piece.add_to_group("Bishop")
		PawnPromotion.PAWN_PROMOTION_KNIGHT:
			change_piece_resources(selected_piece,PieceType.PIECE_TYPE_KNIGHT)
			selected_piece.add_to_group("Knight")
		PawnPromotion.PAWN_PROMOTION_QUEEN:
			change_piece_resources(selected_piece,PieceType.PIECE_TYPE_QUEEN)
			selected_piece.add_to_group("Queen")
	
	selected_piece.player = piece_player
	selected_piece.ready.emit()

extends GameNode3D

signal promotion_requested(piece)

var selected_piece: Node3D

@onready var piece_capture_audio = $Piece_capture
@onready var piece_move_audio = $Piece_move

signal new_turn


func _on_ready() -> void:
	get_tree().call_group("Tile","find_neighbors")


## Selects the given piece
func _on_piece_clicked(new_selected_piece: Node3D) -> void:		
	# unselect piece by clicking on it again
	if selected_piece and new_selected_piece.piece_state(Flag.is_enabled_func, PieceStateFlag.SELECTED):
		new_selected_piece.piece_state(Flag.unset_func, PieceStateFlag.SELECTED)
		get_tree().call_group("Tile","_clear_move_states")
		selected_piece = null

	# select tile by clicking an opponent piece
	elif selected_piece and not new_selected_piece.is_in_group(player_groups[current_player]):
		if (	new_selected_piece.piece_state(Flag.is_enabled_func,PieceStateFlag.THREATENED) 
				and new_selected_piece.get_parent().tile_state(Flag.is_enabled_func,TileStateFlag.THREATENED)
				):
			new_selected_piece.piece_state(Flag.set_func, PieceStateFlag.CAPTURED)
			new_selected_piece.get_parent().tile_selected.emit(new_selected_piece.get_parent())
			piece_capture_audio.play()

	# unselect the current piece and select the new piece
	elif selected_piece and new_selected_piece.player == selected_piece.player and new_selected_piece != selected_piece: 
		selected_piece.piece_state(Flag.unset_func,PieceStateFlag.SELECTED)
		get_tree().call_group("Tile","_clear_move_states")
		new_selected_piece.piece_state(Flag.set_func, PieceStateFlag.SELECTED)
		new_selected_piece.piece_selected.emit()
		selected_piece = new_selected_piece
			
	# select the newly selected piece
	elif not selected_piece: 
		if not new_selected_piece.is_in_group(player_groups[current_player]):
			return
		selected_piece = new_selected_piece
		new_selected_piece.piece_state(Flag.set_func,PieceStateFlag.SELECTED)
		new_selected_piece.piece_selected.emit()


func _on_tile_selected(tile: Node3D) -> void:
	var proceed = true
	if selected_piece.is_in_group("Pawn") and tile.en_passant_occupant and tile.en_passant_occupant != selected_piece:
		tile.en_passant_occupant.piece_state(Flag.set_func, PieceStateFlag.CAPTURED)
		piece_capture_audio.play()
	else:
		piece_move_audio.play()

	
	if tile.tile_state(Flag.is_enabled_func, TileStateFlag.SPECIAL):
		var castling_king = selected_piece
		tile.castle.emit()
		proceed = false
		selected_piece = castling_king
		
	selected_piece.piece_state(Flag.unset_func, PieceStateFlag.SELECTED)
	get_tree().call_group("Tile","_clear_move_states")
	selected_piece.disconnect_from_tile()
	selected_piece.get_parent().tile_occupant = null
	
	tile.tile_occupant = selected_piece
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
			promotion_requested.emit(selected_piece)
			
		if selected_piece.is_in_group("Player_Two") and not tile.neighboring_tiles[Direction.NORTH]:
			selected_piece.remove_from_group("Pawn")
			promotion_requested.emit(selected_piece)
		
		
	selected_piece = null
	if proceed:
		new_turn.emit()


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

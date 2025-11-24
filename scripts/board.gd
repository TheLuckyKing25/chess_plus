extends Node3D


enum {PLAYER_ONE, PLAYER_TWO}

@export var selected_piece: Node3D

signal promotion_requested(selected_piece)


var player_groups:Dictionary = {
	PLAYER_ONE: "Player_One",
	PLAYER_TWO: "Player_Two",
}

var piece_script: Dictionary[int, Resource] = {
	Game.PieceType.PIECE_TYPE_PAWN: preload("res://scripts/pawn.gd"),
	Game.PieceType.PIECE_TYPE_ROOK: preload("res://scripts/rook.gd"),
	Game.PieceType.PIECE_TYPE_BISHOP: preload("res://scripts/bishop.gd"),
	Game.PieceType.PIECE_TYPE_KNIGHT: preload("res://scripts/knight.gd"),
	Game.PieceType.PIECE_TYPE_KING: preload("res://scripts/king.gd"),
	Game.PieceType.PIECE_TYPE_QUEEN: preload("res://scripts/queen.gd"),
}

var piece_mesh: Dictionary = {
	Game.PieceType.PIECE_TYPE_PAWN: preload("res://assets/pawn_mesh.obj"),
	Game.PieceType.PIECE_TYPE_ROOK: preload("res://assets/rook_mesh.obj"),
	Game.PieceType.PIECE_TYPE_BISHOP: preload("res://assets/bishop_mesh.obj"),
	Game.PieceType.PIECE_TYPE_KNIGHT: preload("res://assets/knight_mesh.obj"),
	Game.PieceType.PIECE_TYPE_KING: preload("res://assets/king_mesh.obj"),
	Game.PieceType.PIECE_TYPE_QUEEN: preload("res://assets/queen_mesh.obj"),
}


var turn_num: int = 0


var current_player: int = PLAYER_ONE


func _on_ready() -> void:
	get_tree().call_group("Tile","find_neighbors")


## Selects the given piece
func _on_piece_clicked(new_selected_piece: Node3D) -> void:
	if selected_piece:
		
		# unselect piece by clicking on it again
		if new_selected_piece.piece_state_flag_is_enabled(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED):
			new_selected_piece.unset_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED)
			new_selected_piece.piece_unselected.emit()
			selected_piece = null

		# select tile by clicking an opponent piece
		elif not new_selected_piece.is_in_group(player_groups[current_player]):
			if new_selected_piece.piece_state_flag_is_enabled(Game.PieceStateFlag.PIECE_STATE_FLAG_THREATENED):
				new_selected_piece.set_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CAPTURED)
				new_selected_piece.get_parent().tile_selected.emit(new_selected_piece.get_parent())

		# unselect the current piece and select the new piece
		elif new_selected_piece.player == selected_piece.player and new_selected_piece != selected_piece: 
			selected_piece.unset_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED)
			selected_piece.piece_unselected.emit()
			new_selected_piece.set_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED)
			new_selected_piece.piece_selected.emit()
			selected_piece = new_selected_piece
			
	# select the newly selected piece
	elif not selected_piece: 
		if not new_selected_piece.is_in_group(player_groups[current_player]):
			return
		selected_piece = new_selected_piece
		new_selected_piece.set_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED)
		new_selected_piece.piece_selected.emit()


func _on_tile_selected(tile: Node3D) -> void:
	if selected_piece.is_in_group("Pawn") and tile.en_passant_occupant and tile.en_passant_occupant != selected_piece:
		tile.en_passant_occupant.set_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CAPTURED)
	
	if tile.tile_state_flag_is_enabled(Game.TileStateFlag.TILE_STATE_FLAG_SPECIAL_MOVEMENT):
		var king = selected_piece
		tile.castle.emit()
		selected_piece = king
		
	selected_piece.unset_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_SELECTED)
	selected_piece.piece_unselected.emit()
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
		if selected_piece.is_in_group("Player_One") and not tile.neighboring_tiles[Game.Direction.SOUTH]:
			selected_piece.remove_from_group("Pawn")
			promotion_requested.emit(selected_piece)
			
		if selected_piece.is_in_group("Player_Two") and not tile.neighboring_tiles[Game.Direction.NORTH]:
			selected_piece.remove_from_group("Pawn")
			promotion_requested.emit(selected_piece)
	
	selected_piece = null
	next_turn()

func change_piece_resources(old_piece: Node3D, new_piece: Game.PieceType):
	old_piece.find_child("Piece_Mesh").mesh = piece_mesh[new_piece]
	old_piece.find_child("Outline").mesh = piece_mesh[new_piece]
	old_piece.set_script(piece_script[new_piece])
	

func promote(piece: Node3D, promotion: Game.PawnPromotion):
	var piece_player = piece.player
	
	match promotion:
		Game.PawnPromotion.PAWN_PROMOTION_ROOK:
			change_piece_resources(piece,Game.PieceType.PIECE_TYPE_ROOK)
			piece.add_to_group("Rook")
		Game.PawnPromotion.PAWN_PROMOTION_BISHOP: 
			change_piece_resources(piece,Game.PieceType.PIECE_TYPE_BISHOP)
			piece.add_to_group("Bishop")
		Game.PawnPromotion.PAWN_PROMOTION_KNIGHT:
			change_piece_resources(piece,Game.PieceType.PIECE_TYPE_KNIGHT)
			piece.add_to_group("Knight")
		Game.PawnPromotion.PAWN_PROMOTION_QUEEN:
			change_piece_resources(piece,Game.PieceType.PIECE_TYPE_QUEEN)
			piece.add_to_group("Queen")
	
	piece.player = piece_player
	piece.ready.emit()

### Sets up the next turn
func next_turn() -> void:
		
	# Discover if king is still in check
	for piece in get_tree().get_nodes_in_group(player_groups[(current_player+1)%2]):
		piece.get_parent().discover_checks()
	
	# Clear previous checks
	get_tree().call_group("Tile","clear_checks")
	
	# Discover which pieces check which tiles
	for piece in get_tree().get_nodes_in_group(player_groups[current_player]):
		piece.get_parent().discover_checks()
	
	# increments the turn number and switches the board color
	turn_num += 1
	current_player = (current_player + 1) % 2
	
	get_tree().call_group("Tile","clear_castling_occupant")
	get_tree().call_group("Tile","clear_en_passant",current_player)
	
	%BoardBase.get_surface_override_material(0).albedo_color = Game.COLOR_PALETTE.PLAYER_COLOR[current_player]

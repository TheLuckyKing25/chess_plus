extends Node


enum {PLAYER_ONE, PLAYER_TWO}


@export var selected_piece: Node3D


var player_groups:Dictionary = {
	PLAYER_ONE: "Player_One",
	PLAYER_TWO: "Player_Two",
}

var piece_scenes: Dictionary = {
	Game.PieceType.PIECE_TYPE_PAWN: preload("res://scenes/Pawn.tscn"),
	Game.PieceType.PIECE_TYPE_ROOK: preload("res://scenes/Rook.tscn"),
	Game.PieceType.PIECE_TYPE_BISHOP: preload("res://scenes/Bishop.tscn"),
	Game.PieceType.PIECE_TYPE_KNIGHT: preload("res://scenes/Knight.tscn"),
	Game.PieceType.PIECE_TYPE_KING: preload("res://scenes/King.tscn"),
	Game.PieceType.PIECE_TYPE_QUEEN: preload("res://scenes/Queen.tscn"),
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


func move_to(tile: Node3D) -> void:
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
		Global.print_better(tile.neighboring_tiles)
		if selected_piece.is_in_group("Player_One") and not tile.neighboring_tiles[Game.Direction.SOUTH]:
			promote(Game.PawnPromotion.PAWN_PROMOTION_QUEEN)
		if selected_piece.is_in_group("Player_Two") and not tile.neighboring_tiles[Game.Direction.NORTH]:
			promote(Game.PawnPromotion.PAWN_PROMOTION_QUEEN)
	
	selected_piece = null
	next_turn()


func promote(promotion: Game.PawnPromotion):
	var player_piece_abreviation = ["P1", "P2"]
	match promotion:
		Game.PawnPromotion.PAWN_PROMOTION_ROOK: pass
		Game.PawnPromotion.PAWN_PROMOTION_BISHOP: pass
		Game.PawnPromotion.PAWN_PROMOTION_KNIGHT: pass
		Game.PawnPromotion.PAWN_PROMOTION_QUEEN: pass
	

### Sets up the next turn
func next_turn() -> void:
	
	match (current_player):
		0: 
			for piece in get_tree().get_nodes_in_group("Player_Two"):
				piece.get_parent().discover_checks()
		1: 
			for piece in get_tree().get_nodes_in_group("Player_One"):
				piece.get_parent().discover_checks()
	
	get_tree().call_group("Tile","clear_checks")
	
	match (current_player):
		0: 
			for piece in get_tree().get_nodes_in_group("Player_One"):
				piece.get_parent().discover_checks()
		1: 
			for piece in get_tree().get_nodes_in_group("Player_Two"):
				piece.get_parent().discover_checks()
	
	# increments the turn number and switches the board color
	turn_num += 1
	current_player = (current_player + 1) % 2
	

	
	%BoardBase.get_surface_override_material(0).albedo_color = Game.COLOR_PALETTE.PLAYER_COLOR[current_player]

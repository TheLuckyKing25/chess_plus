class_name Piece
extends GameNode3D

signal piece_clicked(piece: Node3D)


signal piece_selected


signal piece_unselected


@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece_Object.piece_color = COLOR_PALETTE.PLAYER_COLOR[owner_player]
		player = owner_player
		match owner_player:
			0: 
				add_to_group("Player_One")
				remove_from_group("Player_Two")
				rotation = Vector3(0,PI,0)
				parity = -1 
			1: 
				add_to_group("Player_Two")
				remove_from_group("Player_One")
				rotation = Vector3(0,0,0)
				parity = 1 


var parity: int ## determines which direction is the front


var direction_parity: int


var move_rules: Array[MoveRule] 


func moved():
	pass


func connect_to_tile():
	piece_selected.connect(Callable(get_parent(),"_on_occupant_selected"))
	piece_unselected.connect(Callable(get_parent(),"_on_occupant_unselected"))


func disconnect_from_tile():
	piece_selected.disconnect(Callable(get_parent(),"_on_occupant_selected"))
	piece_unselected.disconnect(Callable(get_parent(),"_on_occupant_unselected"))


func piece_state(function:Callable, flag: PieceStateFlag):
	var result = function.call($Piece_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	
	$Piece_Object.state = function.call($Piece_Object.state, flag)
	$Piece_Object.apply_state()


func is_threat_to_en_passant_piece(move:MoveRule, en_passant_piece: Piece) -> bool:
	return (
			is_in_group("Pawn")
			and en_passant_piece 
			and move.action_flag_is_enabled(ActionType.THREATEN)
			and is_opponent_to(en_passant_piece)
		)

func is_threatened_by_en_passant(board_position) -> bool:
	return (	
			is_in_group("Pawn")
			and not is_in_group("has_moved")
			and abs(get_parent().board_position - board_position) == Vector2i(1,0)
		)
		
func is_valid_castling_rook(occupying_piece: Piece) -> bool:
	return (
			occupying_piece
			and occupying_piece.is_in_group("Rook")
			and not is_in_group("has_moved")
			and not is_opponent_to(occupying_piece)
		)

func is_opponent_to(piece: Piece) -> bool:
	return piece and player != piece.player

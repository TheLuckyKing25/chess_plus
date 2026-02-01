class_name Piece
extends GameNode3D

signal clicked(piece: Node3D)


@export_enum("One", "Two") var player


var parity: int ## determines which direction is the front


var direction_parity: int


var move_rules: Array[MoveRule] 


func _ready() -> void:
	$Piece_Object.piece_material.albedo_color = COLOR_PALETTE.PLAYER_COLOR[player]
	match player:
		0: 
			add_to_group("Player_One")
			remove_from_group("Player_Two")
			$Piece_Object.rotate_y(PI)
			parity = 1 
		1: 
			add_to_group("Player_Two")
			remove_from_group("Player_One")
			parity = -1 


func piece_state(function:Callable, flag: PieceStateFlag):
	var result = function.call($Piece_Object.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	$Piece_Object.state = function.call($Piece_Object.state, flag)
	$Piece_Object.apply_state()

func moved():
	pass


func _select():
	piece_state(Flag.set_func, PieceStateFlag.SELECTED)

func _unselect():
	piece_state(Flag.unset_func, PieceStateFlag.SELECTED)


func _threaten():
	piece_state(Flag.set_func, PieceStateFlag.THREATENED)

func _unthreaten():
	piece_state(Flag.unset_func, PieceStateFlag.THREATENED)


func _show_castling():
	piece_state(Flag.set_func, PieceStateFlag.SPECIAL)

func _hide_castling():
	piece_state(Flag.unset_func, PieceStateFlag.SPECIAL)






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
		
func is_opponent_to(piece: Piece) -> bool:
	return piece and player != piece.player

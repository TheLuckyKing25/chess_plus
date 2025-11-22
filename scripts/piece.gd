class_name Piece
extends Node3D

signal piece_clicked(piece: Node3D)
signal piece_selected
signal piece_unselected

@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece.piece_color = Game.COLOR_PALETTE.PLAYER_COLOR[owner_player]
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


func set_piece_state_flag(flag: Game.PieceStateFlag):
	$Piece.state |= 1 << flag
	$Piece.apply_state()


func toggle_piece_state_flag(flag: Game.PieceStateFlag):
	$Piece.state ^= 1 << flag
	$Piece.apply_state()
	
	
func piece_state_flag_is_enabled(flag: Game.PieceStateFlag):
	return $Piece.state & (1 << flag)


func unset_piece_state_flag(flag: Game.PieceStateFlag):
	$Piece.state &= ~(1 << flag)
	$Piece.apply_state()

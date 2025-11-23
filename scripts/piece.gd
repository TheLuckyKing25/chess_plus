class_name Piece
extends Game

signal piece_clicked(piece: Node3D)
signal piece_selected
signal piece_unselected

@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece.piece_color = COLOR_PALETTE.PLAYER_COLOR[owner_player]
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


func piece_state(flag: PieceStateFlag, function:Callable):
	var result = function.call($Piece.state, flag) 
	if typeof(result) == TYPE_BOOL:
		return result
	
	$Piece.state = function.call($Piece.state, flag)
	$Piece.apply_state()

class_name Piece
extends GameNode3D

signal clicked(piece: Node3D)


@export_enum("One", "Two") var player


var parity: int ## determines which direction is the front


var direction_parity: int


var move_rules: Array[MoveRule] 

var is_mouse_on_piece: bool = false

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


func _set_check():
	piece_state(Flag.set_func, PieceStateFlag.CHECKED)

func _unset_check():
	piece_state(Flag.unset_func, PieceStateFlag.CHECKED)

	
func _captured():
	visible = false
	$Piece_Object/Collision.disabled = true
	piece_state(Flag.set_func, PieceStateFlag.CAPTURED)

func promote():
	remove_from_group("Pawn")
	pass

func _on_piece_object_mouse_entered() -> void:
	is_mouse_on_piece = true
	
func _on_piece_object_mouse_exited() -> void:
	is_mouse_on_piece = false
	
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (	event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
			and is_mouse_on_piece
		):
		clicked.emit(self)

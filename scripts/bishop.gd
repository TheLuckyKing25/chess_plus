extends Node3D


signal piece_clicked(piece: Node3D)
signal piece_selected
signal piece_unselected


const BISHOP_MOVE_DISTANCE: int = 8


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


@onready var direction_parity: int = -2 * (parity - 1)


@onready var move_rules: Array[Dictionary] = [
	{"move_flags": Game.MoveType.Movement|Game.MoveType.Threaten, "distance": BISHOP_MOVE_DISTANCE, "direction": (Game.Direction.NORTHEAST + direction_parity) % 8 },
	{"move_flags": Game.MoveType.Movement|Game.MoveType.Threaten, "distance": BISHOP_MOVE_DISTANCE, "direction": (Game.Direction.SOUTHEAST + direction_parity) % 8 },
	{"move_flags": Game.MoveType.Movement|Game.MoveType.Threaten, "distance": BISHOP_MOVE_DISTANCE, "direction": (Game.Direction.SOUTHWEST + direction_parity) % 8 },
	{"move_flags": Game.MoveType.Movement|Game.MoveType.Threaten, "distance": BISHOP_MOVE_DISTANCE, "direction": (Game.Direction.NORTHWEST + direction_parity) % 8 },
]


func _on_ready() -> void:
	piece_clicked.connect(Callable(owner,"_on_piece_clicked"))
	connect_to_tile()


func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
	) -> void:
	if (
			event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
		):
		var mouse_pos = event.position
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos)*1000
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(
				PhysicsRayQueryParameters3D.create(from,to)
			)
		if result:
			var clicked_object = result.collider.get_parent()
			piece_clicked.emit(self)

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

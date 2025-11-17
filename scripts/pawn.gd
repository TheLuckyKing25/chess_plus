extends Node3D


signal piece_clicked(piece: Node3D)

signal piece_selected

signal piece_unselected


const PAWN_MOVE_DISTANCE_INITIAL: int = 2

const PAWN_MOVE_DISTANCE: int = 1

const PAWN_THREATEN_DISTANCE: int = 1


@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece.piece_color = Game.COLOR_PALETTE.PLAYER_COLOR[owner_player]
		player = owner_player
		match (owner_player):
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

var movement_distance: int = PAWN_MOVE_DISTANCE_INITIAL

@onready var direction_parity: int = -2 * (parity - 1)

@onready var move_rules: Array[Dictionary] = [
	{"move_flags": Game.MoveType.Movement, "distance": PAWN_MOVE_DISTANCE_INITIAL, "direction": (Game.Direction.NORTH + direction_parity) % 8 },
	{"move_flags": Game.MoveType.Threaten, "distance": PAWN_THREATEN_DISTANCE, "direction": (Game.Direction.NORTHEAST + direction_parity) % 8 },
	{"move_flags": Game.MoveType.Threaten, "distance": PAWN_THREATEN_DISTANCE, "direction": (Game.Direction.NORTHWEST + direction_parity) % 8 },
]


func _on_ready() -> void:
	piece_clicked.connect(Callable(owner,"_on_piece_clicked"))


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
	connect_to_tile()


func moved():
	move_rules[0].distance = PAWN_MOVE_DISTANCE

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


func connect_to_tile():
	piece_selected.connect(Callable(get_parent(),"_on_occupant_selected"))
	piece_unselected.connect(Callable(get_parent(),"_on_occupant_unselected"))


func disconnect_from_tile():
	piece_selected.disconnect(Callable(get_parent(),"_on_occupant_selected"))
	piece_unselected.disconnect(Callable(get_parent(),"_on_occupant_unselected"))

#func is_en_passant_valid_from(threatened_tile):
	#var new_tile_position_x = get_parent().board_position.x
	#var new_tile_position_y = threatened_tile.board_position.y
	#var new_tile_position = Vector2i(new_tile_position_x,new_tile_position_y)
	#var piece = Tile.find_from_position(new_tile_position).occupant
	#return piece is Pawn and piece.threatened_by_en_passant and threatened_tile == piece.en_passant_tile

#func promote_to(placeholder_variable_piecetype: String):
	#var new_piece_name = placeholder_variable_piecetype + "_" + object.name.get_slice("_", 1)
	#var new_mesh = load(Piece.TYPE[placeholder_variable_piecetype.to_upper()].MESH)
	#object.name = new_piece_name
	#mesh_object.mesh = new_mesh
	#outline_object.mesh = new_mesh
	#player_parent.pawns.erase(self)
	#Board.create_new_piece(player_parent, on_tile, object)

extends Node3D

@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece.mesh_color = Game.PALETTE.PLAYER[owner_player]
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


signal piece_selected
signal piece_unselected

enum { NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST}

enum { Jump = 1, Movement = 2, Threaten = 4, Branch = 8}

## determines which direction is the front
var parity: int 

const PAWN_MOVE_DISTANCE_INITIAL: int = 2
const PAWN_MOVE_DISTANCE: int = 1
const PAWN_THREATEN_DISTANCE: int = 1

@onready var direction_parity: int = -2 * (parity - 1)

@onready var move_rules: Array[Dictionary] = [
	{"move_flags": Movement, "distance": PAWN_MOVE_DISTANCE_INITIAL, "direction": (NORTH + direction_parity) % 8 },
	{"move_flags": Threaten, "distance": PAWN_THREATEN_DISTANCE, "direction": (NORTHEAST + direction_parity) % 8 },
	{"move_flags": Threaten, "distance": PAWN_THREATEN_DISTANCE, "direction": (NORTHWEST + direction_parity) % 8 },
]

func unselect() -> void:
	piece_unselected.emit()
	#for tile in possible_moveset:
		#tile.previous_state()
		#if tile.is_occupied_by_piece_of(Player.current.opponent()):
			#tile.occupant.previous_state()
	#for relation in Global.king_rook_relation:
		#relation["Rook"].previous_state()
	#Global.king_rook_relation.clear()
	$Piece.previous_state()

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
			_on_select()

func _on_ready() -> void:
	piece_selected.connect(Callable(get_parent(),"_on_occupant_selected"))
	piece_unselected.connect(Callable(get_parent(),"_on_occupant_unselected"))


## Selects the given piece
func _on_select() -> void:
	if owner.selected_piece:
		# unselect piece by clicking on it again
		if owner.selected_piece == self:
			unselect()
			owner.selected_piece = null

		## select tile by clicking an opponent piece
		#elif is_piece_of(Player.current.opponent()): 
			#Tile.selected = on_tile

		# unselect the current piece and select the new piece
		elif owner.selected_piece.player == player and owner.selected_piece != self: 
			owner.selected_piece.unselect()
			owner.selected_piece = self
			piece_selected.emit()
			$Piece.set_state($Piece.State.SELECTED)
			
	# select the newly selected piece
	elif not owner.selected_piece: 
		owner.selected_piece = self
		piece_selected.emit()
		$Piece.set_state($Piece.State.SELECTED)
	
	# Highlight tiles if castling applies to selected piece
	#if selected and selected is King:
		#for rook in Player.current.rooks:
			#if not Global.is_castling_legal(selected,rook):
				#continue
			#rook.set_state(State.SPECIAL)
			#var king_position: Vector2i = selected.on_tile.board_position
			#var rook_position: Vector2i = rook.on_tile.board_position
			#var new_position: Vector2i
			#
			#if king_position > rook_position:
				#new_position = king_position + Vector2i(0,-2)
			#elif king_position < rook_position:
				#new_position = king_position + Vector2i(0,2)
				#
			#var king_new_tile: Tile = Tile.find_from_position(new_position)
			#king_new_tile.set_state(State.SPECIAL)
			#selected.castling_moveset.append(king_new_tile)
			#Global.king_rook_relation.append({
				#"Rook": rook, 
				#"King_Destination_Tile": king_new_tile
				#})

#func calculate_complete_moveset() -> void:
	#pawn_threatening_moveset.clear()
	#$Piece.complete_moveset.clear()
	#var max_outward_path: Array[Vector2i] = []
#
	#for distance in range(1,movement_distance+1):
		#var position_transform: Vector2i 
		#var new_position: Vector2i
		#
		#position_transform = (pawn.direction[0] * distance * $Piece.parity)
		#new_position = get_parent().board_position + position_transform
	#
		#$Piece.max_outward_path.append(new_position)
	#$Piece.complete_moveset.append(max_outward_path)
	#
	#for direction in pawn.direction_capture:
		#var position_transform: Vector2i 
		#var new_position: Vector2i
		#
		#position_transform = (direction * $Piece.parity)
		#new_position = get_parent().board_position + position_transform
		#
		#pawn_threatening_moveset.append(new_position)

#func is_en_passant_valid_from(threatened_tile):
	#var new_tile_position_x = get_parent().board_position.x
	#var new_tile_position_y = threatened_tile.board_position.y
	#var new_tile_position = Vector2i(new_tile_position_x,new_tile_position_y)
	#var piece = Tile.find_from_position(new_tile_position).occupant
	#return piece is Pawn and piece.threatened_by_en_passant and threatened_tile == piece.en_passant_tile

#func generate_valid_moveset() -> void:
	#valid_moveset.clear()
	#threatening_moveset.clear()
	#
	#for tile in complete_moveset[0]:
		#if tile.occupant:
			#break
		#else:
			#valid_moveset.append(tile)
			#
			#
	#for tile in pawn_threatening_moveset:
		#var occupant: Piece = tile.occupant
		#if not occupant:
			#
			#if tile in player_parent.opponent().king.possible_moveset:
				#Global.checked_king_moveset.append(tile)
		#
			#if is_en_passant_valid_from(tile):
				#threatening_moveset.append(tile)
			#
			#continue
			#
		#if tile.is_occupied_by_piece_of(player_parent):
			#continue
			#
		#elif occupant.is_king_of(player_parent.opponent()):
			#Global.checking_tiles.append(tile)
			#Global.checking_pieces.append(self)
			#break
		#
		#threatening_moveset.append(tile)
#
#
#func promote_to(placeholder_variable_piecetype: String):
	#var new_piece_name = placeholder_variable_piecetype + "_" + object.name.get_slice("_", 1)
	#var new_mesh = load(Piece.TYPE[placeholder_variable_piecetype.to_upper()].MESH)
	#object.name = new_piece_name
	#mesh_object.mesh = new_mesh
	#outline_object.mesh = new_mesh
	#player_parent.pawns.erase(self)
	#Board.create_new_piece(player_parent, on_tile, object)

extends Node3D

@export_enum("One", "Two") var player:
	set(owner_player):
		$Piece.mesh_color = Game.PALETTE.PLAYER[owner_player]
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

signal piece_selected
signal piece_unselected

enum { NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST}

enum { Jump = 1, Movement = 2, Threaten = 4, Branch = 8}

var direction_parity: int = -2 * (parity - 1)

const KING_MOVE_DISTANCE: int = 1

var move_rules: Array[Dictionary] = [
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (NORTH + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (NORTHEAST + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (EAST + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (SOUTHEAST + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (SOUTH + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (SOUTHWEST + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (WEST + direction_parity) % 8 },
	{"move_flags": Movement|Threaten, "distance": KING_MOVE_DISTANCE, "direction": (NORTHWEST + direction_parity) % 8 },
]

var moveset: Dictionary = {"move_flags": Branch, "branches": []}

#func construct_complete_moveset():
	#for rule in king_move_rules:
		#moveset.branches.append(decode_rule(rule))

func decode_rule(rule):
	var branch: Array = []
	match rule.move_flags:
		Movement|Threaten:
			branch.resize(rule.distance)
			branch.fill({"move_flags": rule.move_flags, "direction": rule.direction + direction_parity})
			return branch
		Branch:
			pass
		Jump:
			pass

#func calculate_moveset():
	#for direction in king.direction:
		#var path: Array[Vector2i] = [] 
		#for distance in range(1,king.distance+1):
			#var movement: Vector2i = direction * distance * parity
			#path.append(movement)
		#moveset.append(path)

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

## determines which direction is the front
var parity: int 

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


## Selects the given piece
#func _on_select() -> void:
	#var selected_piece = get_tree().get_nodes_in_group("is_selected")
	#if selected_piece:
		## unselect piece by clicking on it again
		#if selected_piece == self:
			#unselect()
			#self.remove_from_group("is_selected")
#
		## select tile by clicking an opponent piece
		#elif is_piece_of(Player.current.opponent()): 
			#Tile.selected = on_tile
#
		## unselect the current piece and select the new piece
		#elif is_piece_of(Player.current): 
			#get_tree().call_group("is_selected", "unselect")
#
			#selected = self
			#selected.set_state(State.SELECTED)
			#
	## select the newly selected piece
	#elif not selected and is_piece_of(Player.current): 
		#selected = self
		#selected.set_state(State.SELECTED)
	#
	## Highlight tiles if castling applies to selected piece
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
	#complete_moveset.clear()
	#for direction in king.direction:
		#var max_outward_path: Array[Tile] = []
#
		#for distance in range(1,king.distance+1):
			#var position_transform: Vector2i 
			#var new_position: Vector2i
			#var new_tile: Tile 
			#
			#position_transform = (direction * distance * parity)
			#new_position = on_tile.board_position + position_transform
			#new_tile = Tile.find_from_position(new_position)
			#
			#if not new_tile: 
				#break
#
			#max_outward_path.append(new_tile)
		#complete_moveset.append(max_outward_path)
#
#
#func generate_valid_moveset() -> void:
	#valid_moveset.clear()
	#threatening_moveset.clear()
	#castling_moveset.clear()
	#
	#for max_outward_path in complete_moveset:
		#var valid_path: Array[Tile] = []
		#var king_check: bool = false
		#for tile in max_outward_path:
			#var occupant: Piece = tile.occupant
			#if occupant:
				#if tile.is_occupied_by_piece_of(player_parent):
					#break
				#if king_check:
					#break
			#
				#if occupant.is_king_of(player_parent.opponent()):
					#Global.checking_tiles.append_array(valid_path)
					#Global.checked_king_moveset.append(valid_path.back())
					#Global.checking_pieces.append(self)
					#king_check = true
					#continue
					#
				#threatening_moveset.append(tile)
				#break
			#elif not occupant:
				#if king_check:
					#Global.checked_king_moveset.append(tile)
					#break
				#elif tile in player_parent.opponent().king.possible_moveset:
					#Global.checked_king_moveset.append(tile)
				#valid_path.append(tile)
				#continue
		#valid_moveset.append_array(valid_path)
#
#
#func is_castling_valid() -> bool:
	#return not has_moved and current_state != Piece.State.CHECKED

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

const KNIGHT_OUTWARD_MOVE_DISTANCE: int = 2
const KNIGHT_SIDEWAYS_MOVE_DISTANCE: int = 1

var move_rules: Array[Dictionary] = [
	{"move_flags": Jump|Branch, "distance": KNIGHT_OUTWARD_MOVE_DISTANCE, "direction": (NORTH + direction_parity) % 8,"branches": [
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (EAST + direction_parity) % 8 },
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (WEST + direction_parity) % 8 },
	]},
	{"move_flags": Jump|Branch, "distance": KNIGHT_OUTWARD_MOVE_DISTANCE, "direction": (EAST + direction_parity) % 8, "branches": [
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (NORTH + direction_parity) % 8 },
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (SOUTH + direction_parity) % 8 },
	]},
	{"move_flags": Jump|Branch, "distance": KNIGHT_OUTWARD_MOVE_DISTANCE, "direction": (SOUTH + direction_parity) % 8, "branches": [
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (EAST + direction_parity) % 8 },
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (WEST + direction_parity) % 8 },
	]},
	{"move_flags": Jump|Branch, "distance": KNIGHT_OUTWARD_MOVE_DISTANCE, "direction": (WEST + direction_parity) % 8, "branches": [
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (NORTH + direction_parity) % 8 },
		{"move_flags": Movement|Threaten, "distance": KNIGHT_SIDEWAYS_MOVE_DISTANCE, "direction": (SOUTH + direction_parity) % 8 },
	]},
]

var moveset: Dictionary = {"move_flags": Branch, "branches": []}

#func construct_complete_moveset():
	#for rule in rook_move_rules:
		#moveset.branches.append(decode_rule(rule))

func decode_rule(rule):
	var branch: Array = []
	match rule.move_flags:
		Movement|Threaten:
			branch.resize(rule.distance)
			branch.fill({"move_flags": rule.move_flags, "direction": rule.direction + direction_parity})
		Jump:
			pass
		Branch:
			pass
				
	return branch

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

#func calculate_moveset():
	#for direction in knight.direction:
		#var jump: Array = [direction.jump * parity]
		#var path: Array[Vector2i] = []
		#for move in direction.move: 
			#for distance in range(1,knight.distance + 1):
				#var movement: Vector2i = move * distance * parity
				#path.append(movement)
		#jump.append(path)
		#moveset.append(jump)


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



#func calculate_complete_moveset() -> void:
	#complete_moveset.clear()
	#for direction in knight.direction:
		#var max_outward_path: Array[Tile] = []
#
		#for distance in range(1,knight.distance+1):
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
	#
	#for max_outward_path in complete_moveset:
		#for tile in max_outward_path:
			#var occupant: Piece = tile.occupant
			#if occupant:
				#if tile.is_occupied_by_piece_of(player_parent):
					#break
	#
				#if occupant.is_king_of(player_parent.opponent()):
					#Global.checking_tiles.append(tile)
					#Global.checking_pieces.append(self)
					#continue
				#threatening_moveset.append(tile)
			#elif not occupant:
				#if tile in player_parent.opponent().king.possible_moveset:
					#Global.checked_king_moveset.append(tile)
			#valid_moveset.append(tile)

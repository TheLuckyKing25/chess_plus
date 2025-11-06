extends Node3D
 
@export var board_position: Vector2i
@export var occupant: Node3D = null

enum { Jump = 1, Movement = 2, Threaten = 4, Branch = 8}

enum { NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST}

signal tile_selected

signal moveset_processed(piece: Node3D, direction: String, path: Array[Vector2i])
signal move_processed(piece: Node3D, move: Dictionary)

var neighboring_tiles: Dictionary[int, Node3D] = {
	NORTH: null,
	NORTHEAST:null,
	EAST:null,
	SOUTHEAST:null,
	SOUTH:null,
	SOUTHWEST:null,
	WEST:null,
	NORTHWEST:null
}

func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
) -> void:
	if (
			get_tree().get_node_count_in_group("is_selected") == 1
			and event is InputEventMouseButton
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
			tile_selected.emit()

func is_neighbor(tile: Node3D) -> bool:
	var neighbor_x = tile.board_position.x
	var neighbor_y = tile.board_position.y
	var neighbor_x_diff = abs(neighbor_x - board_position.x)
	var neighbor_y_diff = abs(neighbor_y - board_position.y)
	return (
			neighbor_x_diff == 1 and neighbor_y_diff == 0
			or neighbor_x_diff == 0 and neighbor_y_diff == 1
			or neighbor_x_diff == 1 and neighbor_y_diff == 1
		) 

func _on_ready():
	board_position = Vector2i(name.substr(6,1).to_int(),name.substr(8,1).to_int())
	
	match (board_position.x + board_position.y) % 2:
		0: $Tile_Object.color = Game.PALETTE.TILE_LIGHT
		1: $Tile_Object.color = Game.PALETTE.TILE_DARK
	occupant = find_child("*_P*", false, true)

func find_neighbors():
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("Tile").filter(is_neighbor)
	
	for tile in neighbors:
		var position_difference = board_position - tile.board_position
		match position_difference:
			Vector2i(-1,0): 
				neighboring_tiles[NORTH] = tile
			Vector2i(-1,1): 
				neighboring_tiles[NORTHEAST] = tile
			Vector2i(0,1): 
				neighboring_tiles[EAST] = tile
			Vector2i(1,1): 
				neighboring_tiles[SOUTHEAST] = tile
			Vector2i(1,0): 
				neighboring_tiles[SOUTH] = tile
			Vector2i(1,-1): 
				neighboring_tiles[SOUTHWEST] = tile
			Vector2i(0,-1): 
				neighboring_tiles[WEST] = tile
			Vector2i(-1,-1): 
				neighboring_tiles[NORTHWEST] = tile

func _on_paths_recieved(piece:Node3D,direction:int,path:Array):
	#print(direction," ", board_position," ", path)
	path.remove_at(0)
	if not path.is_empty():
		moveset_processed.connect(Callable(neighboring_tiles[direction],"_on_paths_recieved"))
		moveset_processed.emit(piece,direction,path)
		moveset_processed.disconnect(Callable(neighboring_tiles[direction],"_on_paths_recieved"))
	
	if $Tile_Object.current_state == $Tile_Object.State.NONE:
		$Tile_Object.set_state($Tile_Object.State.VALID)
	elif $Tile_Object.current_state == $Tile_Object.State.VALID:
		$Tile_Object.set_state($Tile_Object.State.NONE)

var moveset: Dictionary = {"move_flags": Branch, "branches": []}

func propagate_move(move, direction:int):
	move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	move_processed.emit(occupant, move)
	move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	
func print_array(array, indent:int = 0):
	for item in array:
		if typeof(item) == TYPE_ARRAY:
			print("\t".repeat(indent),"[")
			print_array(item, indent+1)
			print("\t".repeat(indent), "],")
		elif typeof(item) == TYPE_DICTIONARY:
			print("\t".repeat(indent), "{")
			print_dict(item, indent+1)
			print("\t".repeat(indent), "},")
		else:
			print("\t".repeat(indent), item ,", ")
	
func print_dict(dict, indent:int = 0):
	for item in dict:
		if typeof(dict[item]) == TYPE_ARRAY:
			print("\t".repeat(indent), item ,": [")
			print_array(dict[item], indent+1)
			print("\t".repeat(indent), "]")
		elif typeof(dict[item]) == TYPE_DICTIONARY:
			print("\t".repeat(indent), item ,": {")
			print_dict(dict[item], indent+1)
			print("\t".repeat(indent), "}")
		else:
			print("\t".repeat(indent), item ,": ", dict[item])

func print_better(tree):
	if typeof(tree) == TYPE_DICTIONARY:
		print_dict(tree)
	elif typeof(tree) == TYPE_ARRAY:
		print_array(tree)
	else:
		print(tree)

func evaluate_move(move:Dictionary):
	if move.move_flag&Movement:
		pass
	pass #determine tile state based on move_flags

func _on_moves_recieved(piece:Node3D, moves):
	var assigned_move
	if typeof(moves) == TYPE_DICTIONARY and (moves.move_flags & Branch):
		var new_branches = construct_branches(moves.branches)
		moves.branches = new_branches
		print(piece.direction_parity)
		for move in moves.branches:
			propagate_move(move, move[0].direction)
	
	elif typeof(moves) == TYPE_ARRAY:
		assigned_move = moves.pop_front()
		if moves.size() > 0:
			propagate_move(moves, moves[0].direction)
	
	evaluate_move(assigned_move)
	
	if $Tile_Object.current_state == $Tile_Object.State.NONE:
		$Tile_Object.set_state($Tile_Object.State.VALID)
	elif $Tile_Object.current_state == $Tile_Object.State.VALID:
		$Tile_Object.set_state($Tile_Object.State.NONE)
	
		
func construct_branches(rule_set:Array):
	var branches: Array = []
	for rule in rule_set:
		var branch: Array = []
		if (rule.move_flags & Movement|Threaten) and not (rule.move_flags & Jump):
			branch.resize(branch.size() + rule.distance)
			branch.fill({"move_flags": (rule.move_flags & Movement)|(rule.move_flags&Threaten), "direction": rule.direction})
		if (rule.move_flags & Jump):
			branch.resize(branch.size() + rule.distance)
			branch.fill({"move_flags": Jump, "direction": rule.direction})
		if (rule.move_flags & Branch):
			branch[-1].move_flags |= Branch
			branch[-1].set("branches", rule.branches)
		branches.append(branch)
	return branches


func _on_occupant_selected():
	$Tile_Object.set_state($Tile_Object.State.SELECTED)
	moveset.branches.assign(occupant.move_rules)
	_on_moves_recieved(occupant,moveset)


func _on_occupant_unselected():
	moveset.branches.assign(occupant.move_rules)
	_on_moves_recieved(occupant,moveset)
	$Tile_Object.set_state_previous()
	
## Piece on the tile, if any
#var en_passant_occupant = null
#
#func is_occupied_by_piece_of(player: Player) -> bool:
	#return true #occupant and occupant in player.pieces
#
#
### Checks if a selected tile is within the valid movement of the piece
#func is_valid_move(piece, player: Player) -> bool: 
	#return (
		#self in piece.possible_moveset 
		#or (
			#not Game.Settings.options[Game.Settings.DEBUG_RESTRICT_MOVEMENT] 
			#and not is_occupied_by_piece_of(player)
		#)
	#)	
#
#
#func is_threatened_by(opposing_player:Player) -> bool:
	#return self in opposing_player.all_threatened_tiles


		

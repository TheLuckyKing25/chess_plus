extends Node3D


signal tile_selected(tile:Node3D)

signal move_processed(piece: Node3D, move: Dictionary)

signal checks_processed(piece: Node3D, move: Dictionary, from:Game.Direction) 

@export var board_position: Vector2i

@export var occupant: Node3D = null


var checked_by: Array = []

var moveset: Dictionary = {"move_flags": Game.MoveType.Branch, "branches": []}

var neighboring_tiles: Dictionary[int, Node3D] = {
	Game.Direction.NORTH: null,
	Game.Direction.NORTHEAST:null,
	Game.Direction.EAST:null,
	Game.Direction.SOUTHEAST:null,
	Game.Direction.SOUTH:null,
	Game.Direction.SOUTHWEST:null,
	Game.Direction.WEST:null,
	Game.Direction.NORTHWEST:null
}

func _on_ready():
	tile_selected.connect(Callable(owner,"move_to"))
	board_position = Vector2i(name.substr(6,1).to_int(),name.substr(8,1).to_int())
	match (board_position.x + board_position.y) % 2:
		0: $Tile_Object.tile_color = Game.COLOR_PALETTE.TILE_COLOR_LIGHT
		1: $Tile_Object.tile_color = Game.COLOR_PALETTE.TILE_COLOR_DARK
	occupant = find_child("*_P*", false, true)


func _on_occupant_selected():
	set_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_SELECTED)
	moveset.branches.assign(occupant.move_rules)
	_on_moves_recieved(occupant, moveset)


func _on_occupant_unselected():
	unset_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_SELECTED)
	moveset.branches.assign(occupant.move_rules)
	_on_moves_recieved(occupant, moveset)


func _on_input_event(
		camera: Node, 
		event: InputEvent, 
		event_position: Vector3, 
		normal: Vector3, 
		shape_idx: int
) -> void:
	if (
			owner.selected_piece
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
			if tile_state_flag_is_enabled(Game.TileStateFlag.TILE_STATE_FLAG_MOVEMENT):
				tile_selected.emit(self)
			
func _on_moves_recieved(piece:Node3D, moves):
	var assigned_move: Dictionary
	
	if typeof(moves) == TYPE_ARRAY:
		assigned_move = moves.pop_front()
	elif typeof(moves) == TYPE_DICTIONARY:
		assigned_move = moves
	
	if occupant: 
		if assigned_move.move_flags & Game.MoveType.Threaten and occupant.player != piece.player:
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_THREATENED)
			occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_THREATENED)
		if not assigned_move.move_flags & Game.MoveType.Jump and occupant != piece:
			return
	elif not occupant:
		if assigned_move.move_flags & Game.MoveType.Movement:
			toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_MOVEMENT)
			
	if typeof(moves) == TYPE_DICTIONARY and (assigned_move.move_flags & Game.MoveType.Branch):
		var new_branches = construct_branches(assigned_move.branches)
		assigned_move.branches = new_branches
		for move in assigned_move.branches:
			send_move(piece, move, move[0].direction)
	elif typeof(moves) == TYPE_ARRAY:
		if moves.size() == 1:
			send_move(piece, moves[0], moves[0].direction)
		elif moves.size() > 1:
			send_move(piece, moves, moves[0].direction)


func _on_checks_recieved(piece:Node3D, moves, from: Game.Direction):
	var assigned_move: Dictionary
	
	if typeof(moves) == TYPE_ARRAY:
		assigned_move = moves.pop_front()
	elif typeof(moves) == TYPE_DICTIONARY:
		assigned_move = moves

	if assigned_move.move_flags & Game.MoveType.Threaten:
		checked_by.append(piece)
	if occupant and occupant.is_in_group("King") and occupant.player != piece.player:
		
		if occupant.piece_state_flag_is_enabled(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED):
			print("END GAME")
			
		toggle_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_CHECKED)
		occupant.toggle_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED)
	elif occupant and (not occupant.is_in_group("King") or occupant.player == piece.player): 
		if not assigned_move.move_flags & Game.MoveType.Jump and occupant != piece:
			return	
			
	if typeof(moves) == TYPE_DICTIONARY and (assigned_move.move_flags & Game.MoveType.Branch):
		var new_branches = construct_branches(assigned_move.branches)
		assigned_move.branches = new_branches
		for move in assigned_move.branches:
			send_checks(piece, move, move[0].direction)
	elif typeof(moves) == TYPE_ARRAY:
		if moves.size() == 1:
			send_checks(piece, moves[0], moves[0].direction)
		elif moves.size() > 1:
			send_checks(piece, moves, moves[0].direction)

func clear_checks():
	checked_by = []
	unset_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_CHECKED)
	unset_tile_state_flag(Game.TileStateFlag.TILE_STATE_FLAG_CHECKING)
	if occupant:
		occupant.unset_piece_state_flag(Game.PieceStateFlag.PIECE_STATE_FLAG_CHECKED)

func discover_checks():
	if occupant:
		moveset.branches.assign(occupant.move_rules)
		_on_checks_recieved(occupant, moveset, 9)

func set_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state |= 1 << flag
	$Tile_Object.apply_state()


func toggle_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state ^= 1 << flag
	$Tile_Object.apply_state()

	
func tile_state_flag_is_enabled(flag: Game.TileStateFlag):
	return $Tile_Object.state & (1 << flag)


func unset_tile_state_flag(flag: Game.TileStateFlag):
	$Tile_Object.state &= ~(1 << flag)
	$Tile_Object.apply_state()


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


func find_neighbors():
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("Tile").filter(is_neighbor)
	for tile in neighbors:
		var position_difference = board_position - tile.board_position
		match position_difference:
			Vector2i(-1,0): 
				neighboring_tiles[Game.Direction.NORTH] = tile
			Vector2i(-1,1): 
				neighboring_tiles[Game.Direction.NORTHEAST] = tile
			Vector2i(0,1): 
				neighboring_tiles[Game.Direction.EAST] = tile
			Vector2i(1,1): 
				neighboring_tiles[Game.Direction.SOUTHEAST] = tile
			Vector2i(1,0): 
				neighboring_tiles[Game.Direction.SOUTH] = tile
			Vector2i(1,-1): 
				neighboring_tiles[Game.Direction.SOUTHWEST] = tile
			Vector2i(0,-1): 
				neighboring_tiles[Game.Direction.WEST] = tile
			Vector2i(-1,-1): 
				neighboring_tiles[Game.Direction.NORTHWEST] = tile


func send_move(piece:Node3D, moves, direction:int):	
	move_processed.connect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	move_processed.emit(piece, moves)
	move_processed.disconnect(Callable(neighboring_tiles[direction],"_on_moves_recieved"))
	
func send_checks(piece:Node3D, moves, direction:int):	
	checks_processed.connect(Callable(neighboring_tiles[direction],"_on_checks_recieved"))
	checks_processed.emit(piece, moves, (direction + 4) % 8)
	checks_processed.disconnect(Callable(neighboring_tiles[direction],"_on_checks_recieved"))
		
func construct_branches(rule_set:Array):
	var branches: Array = []
	for rule in rule_set:
		var branch: Array = []
		if (rule.move_flags & Game.MoveType.Movement|Game.MoveType.Threaten) and not (rule.move_flags & Game.MoveType.Jump):
			branch.resize(branch.size() + rule.distance)
			for move_index in range(0,branch.size()):
				if branch[move_index] == null:
					branch[move_index] = {"move_flags": (rule.move_flags & Game.MoveType.Movement)|(rule.move_flags& Game.MoveType.Threaten), "direction": rule.direction}
		if (rule.move_flags & Game.MoveType.Jump):
			branch.resize(branch.size() + rule.distance)
			for move_index in range(0,branch.size()):
				if branch[move_index] == null:
					branch[move_index] = {"move_flags": Game.MoveType.Jump, "direction": rule.direction}
		if (rule.move_flags & Game.MoveType.Branch):
			branch[-1].move_flags |= Game.MoveType.Branch
			branch[-1].set("branches", rule.branches)
		branches.append(branch)
	return branches

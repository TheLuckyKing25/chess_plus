class_name Tile

enum State{
		NONE,
		SELECTED,
		VALID,
		THREATENED,
		CHECKED,
		CHECKING,
		MOVE_CHECKING,
		SPECIAL,
	}

static var selected: Tile = null


## Position of the tile on the board
var board_position: Vector2i


var collision: CollisionShape3D


## Color of the mesh object
var color: Color: 
	set(new_color):
		color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color


var current_state: State = State.NONE


var mesh: MeshInstance3D


## Node containing the Mesh and CollisionBox
var object_tile: Node3D:
	set(node):
		object_tile = node
		mesh = node.find_child("Mesh")
		collision = node.find_child("Collision")


## Piece on the tile, if any
var occupant: Piece = null
var en_passant_occupant: Piece = null

var state_color: Color: 
	set(new_color):
		state_color = new_color
		mesh.get_surface_override_material(0).albedo_color = new_color


var state_order: Array[State] = []


## Returns the tile class with an object that has the given name.
## Returns null if no tile class can be found.
static func find_from_name(tile_name: String) -> Tile:
	for tile in Board.all_tiles: 
		if tile.object_tile.name == tile_name:
			return tile
	return null


## Returns the tile class of the given tile object.
## Returns null if no tile class can be found.
static func find_from_object(tile_object: Node3D) -> Tile:
	for tile in Board.all_tiles: 
		if tile.object_tile == tile_object:
			return tile
	return null


## Returns the tile class at the given position.
## Returns null if no tile class can be found.
static func find_from_position(tile_position: Vector2i) -> Tile:
	for tile in Board.all_tiles: 
		if tile.board_position == tile_position:
			return tile
	return null
	

func _init(tile_position: Vector2i, tile_object: Node3D) -> void:
	board_position = tile_position
	object_tile = tile_object
	match (tile_position[0] + tile_position[1]) % 2:
		0: 
			color = Game.Colour.PALETTE[Game.Colour.TILE_LIGHT]
		1: 
			color = Game.Colour.PALETTE[Game.Colour.TILE_DARK]
	
	
func _set_color_to(color_value:= Color(1,1,1)) -> void:
	state_color = color * color_value

	
func is_occupied_by_piece_of(player: Player) -> bool:
	return occupant and occupant in player.pieces


## Checks if a selected tile is within the valid movement of the piece
func is_valid_move(piece: Piece, player: Player) -> bool: 
	return (
		self in piece.possible_moveset 
		or (
			not Game.Settings.options[Game.Settings.DEBUG_RESTRICT_MOVEMENT] 
			and not is_occupied_by_piece_of(player)
		)
	)	


func is_threatened_by(opposing_player:Player) -> bool:
	return self in opposing_player.all_threatened_tiles
	

func previous_state() -> void:
	if not state_order.is_empty():
		set_state(state_order.pop_back())
	else:
		set_state(State.NONE)
		

func set_state(new_state: State) -> void:
	if new_state != State.SPECIAL:
		mesh.get_surface_override_material(0).emission_enabled = false
	match new_state:
		
		State.NONE: 
			_set_color_to()
			state_order.clear()
			
		State.SELECTED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			if current_state != State.CHECKED:
				_set_color_to(Game.Colour.PALETTE[Game.Colour.SELECT_TILE])
				
		State.VALID:
			if current_state != State.NONE:
				state_order.append(current_state)
			if current_state != State.MOVE_CHECKING:
				_set_color_to(Game.Colour.PALETTE[Game.Colour.VALID_TILE])
				
		State.THREATENED:
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.Colour.PALETTE[Game.Colour.THREATENED_TILE])
			
		State.CHECKED: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.Colour.PALETTE[Game.Colour.CHECKED_TILE])
			
		State.CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			if Game.Settings.options[Game.Settings.SHOW_CHECKING_PIECE_PATH]:
				_set_color_to(Game.Colour.PALETTE[Game.Colour.CHECKING_TILE])
				
		State.MOVE_CHECKING: 
			if current_state != State.NONE:
				state_order.append(current_state)
			_set_color_to(Game.Colour.PALETTE[Game.Colour.MOVE_CHECKING_TILE])
			
		State.SPECIAL:
			if current_state != State.NONE:
				state_order.append(current_state)
			state_color = Game.Colour.PALETTE[Game.Colour.SPECIAL_TILE]
			mesh.get_surface_override_material(0).emission_enabled = true
	
	current_state = new_state

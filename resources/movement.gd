class_name Movement
extends Resource

static var neighboring_tiles: Dictionary[Direction, Vector2i] = {
	Direction.NORTH: Vector2i(1,0),
	Direction.NORTHEAST: Vector2i(1,1),
	Direction.EAST: Vector2i(0,1),
	Direction.SOUTHEAST: Vector2i(-1,1),
	Direction.SOUTH: Vector2i(-1,0),
	Direction.SOUTHWEST: Vector2i(-1,-1),
	Direction.WEST: Vector2i(0,-1),
	Direction.NORTHWEST: Vector2i(1,-1)
}


enum Direction{ 
	NONE = -1, ## Only to be used when  [param Distance]  equals  [code]0[/code].
	NORTH = 0, 
	NORTHEAST = 1, 
	EAST = 2, 
	SOUTHEAST = 3, 
	SOUTH = 4, 
	SOUTHWEST = 5, 
	WEST = 6, 
	NORTHWEST = 7,
	}

enum Purpose{ 
	UNSET = 0,
	STANDARD_MOVEMENT = 1,
	GENERATE_ALL_MOVES = 2,
	}

## The distance that this move will extend out to.
## Setting the value to  [code]-1[/code]  will make the value
## equal to the largest side length of the board.
@export_range(-1,8,1,"or_greater") var distance: int = 0

@export var direction: Direction:
	set(cardinal):
		if cardinal <= Direction.NONE:
			direction = Direction.NONE
		else:	
			direction = (cardinal % 8)
	

# Actions performed by the piece on a tile	
@export var is_jump: bool = false # Continue through occupied tile
@export var is_move: bool = false # Tile unoccupied
@export var is_threaten: bool = false # Tile occupied by opponent
@export var is_branching: bool = false # Branch from tile, flag set on last moverule of a branch
@export var is_special: bool = false # Used for special movements, flag set on last moverule of a branch


@export var branches: Array[Movement]

# Purpose of the movement
# The same throughout entire moveset
var purpose: Purpose = Purpose.UNSET

func _init():
	resource_local_to_scene = true

func get_duplicate():
	var duplicated_movement:Movement = duplicate(true)
	if duplicated_movement.is_branching:
		var duplicated_movement_branches:Array[Movement] = []
		for branch in duplicated_movement.branches:
			duplicated_movement_branches.append(branch.get_duplicate())
		duplicated_movement.branches = duplicated_movement_branches
	
	return duplicated_movement


func rotate_movement():
	pass

func set_purpose_type(new_purpose: Purpose):
	purpose = new_purpose
	if is_branching:
		for branch in branches:
			branch.set_purpose_type(new_purpose)

func set_max_distance(max_distance:int):
	if distance == -1:
		distance = max_distance
	if is_branching:
		for branch in branches:
			branch.set_max_distance(max_distance)

func change_movement_distance():
	pass

func set_direction_parity(direction_parity: int):
	if direction != Direction.NONE:
		direction = (direction + direction_parity) % 8
	if is_branching:
		for branch in branches:
			branch.set_direction_parity(direction_parity)

static func extract_moves_from_movement(active_piece:Piece, moveset: Movement, origin_tile: Tile):
	var movements: Array[Move] = []
	
	for branch in moveset.branches:
		var current_tile_ptr: Tile = origin_tile
		
		branch.purpose = moveset.purpose
		var distance: int = branch.distance
		
		while distance > 0:
			if current_tile_ptr == null:
				break
				
			var next_tile_position: Vector2i = current_tile_ptr.board_position + Movement.neighboring_tiles[branch.direction]
				
			if (next_tile_position.x > Board.rank_count-1 
					or next_tile_position.x < 0
					or next_tile_position.y > Board.file_count-1
					or next_tile_position.y < 0):
				break
			else:
				current_tile_ptr = Board.tile_array[Tile.get_index(next_tile_position.x,next_tile_position.y)]
			
			
			if branch.is_threaten:
				if current_tile_ptr.occupant: # current_tile_ptr is occupied
					if active_piece.player != current_tile_ptr.occupant.player: # current_tile_ptr is occupied by opponent piece
						movements.append(Move.new(Board.tile_array[active_piece.index],current_tile_ptr))
						break	
			
			if not branch.is_jump:
				if current_tile_ptr.occupant: # current_tile_ptr is occupied			
					if active_piece != current_tile_ptr.occupant: # current_tile_ptr not is occupied by active piece
						break
			
			if branch.is_move:
				if current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					movements.append(Move.new(Board.tile_array[active_piece.index],current_tile_ptr))
			
			if current_tile_ptr == Tile.en_passant:
				if current_tile_ptr.occupant == null: # current_tile_ptr is not occupied
					movements.append(Move.new(Board.tile_array[active_piece.index],current_tile_ptr))
			
			distance -= 1
			
		if distance == 0 and branch.is_branching:
			movements.append_array(extract_moves_from_movement(active_piece, branch, current_tile_ptr))
	
		return movements

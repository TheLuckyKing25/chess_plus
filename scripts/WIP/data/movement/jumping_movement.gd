class_name JumpingMovement extends AbstractMovement

# define several different directions and add their vectors together
@export_range(-16,16,1,"suffix:Rows") var row_origin_offset:int
@export_range(-16,16,1,"suffix:Files") var file_origin_offset:int

# Actions performed by the piece on a tile
@export var is_move := false # Tile unoccupied
@export var is_threaten := false # Tile occupied by opponent
@export var is_castling := false # Used for castling movements, flag set on last moverule of a branch

@export var next_movement: AbstractMovement

var is_branching: bool:
	get():
		if next_movement is BranchingMovement:
			return false
		else:
			return true

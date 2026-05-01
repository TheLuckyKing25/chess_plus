@tool
class_name JumpingMovement extends AbstractMovement

# define several different directions and add their vectors together
@export_range(-16,16,1,"suffix:Ranks") var row_origin_offset:int
@export_range(-16,16,1,"suffix:Files") var file_origin_offset:int

var offset_vector: Vector2i:
	get:
		return Vector2i(row_origin_offset,file_origin_offset)

@export var is_move := false
@export var is_threaten := false
@export var is_castling := false

@export var next_movement: AbstractMovement

var is_branching: bool:
	get():
		if next_movement is BranchingMovement:
			return false
		else:
			return true

func set_direction_parity(direction_parity:int):
	if direction_parity == 4:
		row_origin_offset *= -1
		file_origin_offset *= -1

func get_duplicate() -> AbstractMovement:
	var duplicated_movement: JumpingMovement = duplicate()
	if next_movement:
		duplicated_movement.next_movement = next_movement.get_duplicate()
	return duplicated_movement

func apply_movement(current_tile:TileObject):
	# find next_tile
	var new_position = current_tile.data.board_position + offset_vector
	var next_tile = Match.board.data.find_tile_using_vector(new_position)
	if next_tile == null:
		return

	# enter next_tile
		# apply modifiers of next_tile

	# apply states to next_tile

	# exit next_tile
	if next_movement:
		next_movement.apply_movement(next_tile)
	pass

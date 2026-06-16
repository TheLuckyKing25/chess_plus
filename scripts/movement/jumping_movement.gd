@tool
class_name JumpingMovement extends AbstractMovement

@export_range(-16,16,1,"suffix:Ranks") var rank_origin_offset:int
@export_range(-16,16,1,"suffix:Files") var file_origin_offset:int

var offset_vector: Vector2i:
	get:
		return Vector2i(rank_origin_offset,file_origin_offset)

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
		rank_origin_offset *= -1
		file_origin_offset *= -1
	if is_instance_valid(next_movement):
		next_movement.set_direction_parity(direction_parity)


func apply_movement(current_tile:TileDataChess, _board: BoardData) -> Dictionary[TileDataChess,ObjectStateComponent.Type]:
	var tiles: Dictionary[TileDataChess,ObjectStateComponent.Type] = {}

	# find next_tile
	var new_position:Vector2i = current_tile.position_vector + offset_vector

	if _board.board_representation.get(new_position) == null:
		return {}

	var next_tile:TileDataChess = _board.board_representation.get(new_position).get(BoardData.TILE_DATA)
	var next_tile_state: ObjectStateComponent.Type = ObjectStateComponent.Type.NONE
	if not is_instance_valid(next_tile):
		return {}

	# enter next_tile
		# apply modifiers of next_tile

	if is_move:
		if next_tile.occupant == null:
			next_tile_state = ObjectStateComponent.Type.MOVEMENT
			tiles.set(next_tile,next_tile_state)

	if is_threaten:
		if is_instance_valid(next_tile.occupant) and not next_tile in _board.valid_selections:
			next_tile_state = ObjectStateComponent.Type.THREATENED
			tiles.set(next_tile,next_tile_state)

	if next_tile_state == ObjectStateComponent.Type.NONE:
		return {}

	# exit next_tile

	if next_movement != null:
		tiles.merge(next_movement.apply_movement(next_tile, _board))

	return tiles

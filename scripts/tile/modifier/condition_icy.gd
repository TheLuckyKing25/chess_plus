class_name ConditionIcy
extends TileModifier

# The icy condition slides a piece an additional one tile in the direction they moved.

## The number of turns that the Icy condition remains on a tile, 
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int

func _init():
	flag = ModifierEnums.TileModifierFlag.CONDITION_ICY

func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	if from_tile == null or to_tile == null:
		return
	
	var delta: Vector2i = to_tile.data.board_position - from_tile.data.board_position
	if delta == Vector2i.ZERO:
		return
	
	# Normalize delta or else the piece will double movement rather than 1 tile
	delta.x = sign(delta.x)
	delta.y = sign(delta.y)
	
	var next_pos: Vector2i = to_tile.data.board_position + delta
	
	if next_pos.x < 0 or next_pos.x >= board.data.rank_count:
		return
	if next_pos.y < 0 or next_pos.y >= board.data.file_count:
		return
	
	var next_tile = board.data.tile_array[board.data.get_index(next_pos.x, next_pos.y)]
	if next_tile == null:
		return
	if next_tile.occupant != null:
		return
	
	board.perform_move(Move.new(to_tile, next_tile))

class_name Bishop 
extends Piece

func _init(parent_tile: Tile, piece_object: Node3D) -> void:
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = Global.BISHOP_MOVEMENT_DIRECTIONS
	movement_distance = 8

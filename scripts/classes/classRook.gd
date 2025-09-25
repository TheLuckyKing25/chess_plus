class_name Rook 
extends Piece

func _init(parent_tile: Tile, piece_object: Node3D) -> void:
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = Global.ROOK_MOVEMENT_DIRECTIONS
	movement_distance = 8

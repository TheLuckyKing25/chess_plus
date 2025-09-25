class_name King 
extends Piece

func _init(parent_tile: Tile, piece_object: Node3D):
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = Global.KING_MOVEMENT_DIRECTIONS
	movement_distance = 1

class_name Knight 
extends Piece

func _init(parent_tile: Tile, piece_object: Node3D):
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = Global.KNIGHT_MOVEMENT_DIRECTIONS
	movement_distance = 1

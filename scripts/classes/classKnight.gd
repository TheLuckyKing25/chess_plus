class_name Knight 
extends Piece

func _init(parent_tile: Tile, piece_object: Node3D):
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = [
		Vector2i(1,2), 
		Vector2i(2,1), 
		Vector2i(-1,2), 
		Vector2i(-2,1), 
		Vector2i(1,-2), 
		Vector2i(2,-1), 
		Vector2i(-1,-2),
		Vector2i(-2,-1)
		]
	movement_distance = 1

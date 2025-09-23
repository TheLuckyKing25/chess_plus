class_name King 
extends Piece

var moved: bool = false

func _init(parent_tile: Tile, piece_object: Node3D):
	tile_parent = parent_tile
	object_piece = piece_object
	movement_direction = [
		Vector2i(1,0), 
		Vector2i(1,1), 
		Vector2i(0,1), 
		Vector2i(-1,1), 
		Vector2i(-1,0), 
		Vector2i(1,-1), 
		Vector2i(0,-1), 
		Vector2i(-1,-1)
		]
	movement_distance = 1

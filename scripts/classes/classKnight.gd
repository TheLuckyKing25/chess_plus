class_name Knight 
extends Piece

func _init(piece_tile: Tile, piece_object: Node3D):
	tile = piece_tile
	object = piece_object
	movement_direction = [
		Vector2(1,2), 
		Vector2(2,1), 
		Vector2(-1,2), 
		Vector2(-2,1), 
		Vector2(1,-2), 
		Vector2(2,-1), 
		Vector2(-1,-2),
		Vector2(-2,-1)
		]
	movement_distance = 1
